function [structsAreSimilarWithinSpecifiedTolerance, result] = structsAreSimilar(obj, groundTruthData, validationData, customTolerances)

    tolerance           = obj.validationParams.numericTolerance;
    graphMismatchedData = obj.validationParams.graphMismatchedData;
    compareStringFields = obj.validationParams.compareStringFields;
    
    result = {};
    result = recursivelyCompareStructs(obj, ...
        'groundTruthData', groundTruthData, ...
        'validationData', validationData, ...
        tolerance, customTolerances, graphMismatchedData, compareStringFields, result);
                                   
    if (isempty(result))
        structsAreSimilarWithinSpecifiedTolerance = true;
    else
       structsAreSimilarWithinSpecifiedTolerance = false;
    end
end

function result = recursivelyCompareStructs(obj, struct1Name, struct1, struct2Name, struct2, tolerance, customTolerances, graphMismatchedData, compareStringFields, oldResult)

    result = oldResult;

    if (isempty(struct1)) && (isempty(struct2))
        return;
    elseif (isempty(struct1)) && (~isempty(struct2))
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('''%s'' is empty whereas ''%s'' is not. Will not compare further.', struct1Name, struct2Name);
        return;
    elseif (~isempty(struct1)) && (isempty(struct2))
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('''%s'' is not empty whereas ''%s'' is empty. Will not compare further.', struct1Name, struct2Name);
        return;
    end
    
    % Check for non-struct inputs
    if (~isstruct(struct1)) 
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('''%s'' is not a struct. Will not compare further.', struct1Name);
        return;
    end
    
    if (~isstruct(struct1)) 
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('''%s'' is not a struct. Will not compare further.', struct2Name);
        return;
    end
    
    if (numel(struct1) ~= numel(struct2))
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('''%s'' and ''%s'' are struct arrays of different lengths (%d vs %d). Will not compare further.', struct1Name, struct2Name, numel(struct1), numel(struct2));
        return;
    end
    
    % OK, inputs are good structs so lets continue with their fields
    theStruct1Name = struct1Name;
    theStruct2Name = struct2Name;
    
    for structIndex = 1:numel(struct1)
        struct1Name = sprintf('%s(%d)', theStruct1Name, structIndex);
        struct2Name = sprintf('%s(%d)', theStruct2Name, structIndex);
        
        struct1FieldNames = sort(fieldnames(struct1));
        struct2FieldNames = sort(fieldnames(struct2));
    
        % Check that the two structs have same number of fields
        if numel(struct1FieldNames) ~= numel(struct2FieldNames)
            resultIndex = numel(result)+1;
            result{resultIndex} = sprintf('''%s'' has %d fields, whereas ''%s'' has %d fields. Will not compare further.', struct1Name, numel(struct1FieldNames), struct2Name, numel(struct2FieldNames));
            return;
        end
    
        for k = 1:numel(struct1FieldNames)
        
            % Check that the two structs have the same field names
            if (strcmp(struct1FieldNames{k}, struct2FieldNames{k}) == 0)
                resultIndex = numel(result)+1;
                result{resultIndex} = sprintf('''%s'' and ''%s'' have different field names: ''%s'' vs ''%s''. Will not compare further.', struct1Name, struct2Name, struct1FieldNames{k}, struct2FieldNames{k});
                return;
            end
    
            field1Name = sprintf('%s.%s', struct1Name, struct1FieldNames{k});
            field2Name = sprintf('%s.%s', struct2Name, struct2FieldNames{k});
       
            field1 = [];
            field2 = [];
            eval(sprintf('field1 = struct1(structIndex).%s;', struct1FieldNames{k}));
            eval(sprintf('field2 = struct2(structIndex).%s;', struct2FieldNames{k}));
       
            % compare structs
            if isstruct(field1)
                if isstruct(field2)
                    result = recursivelyCompareStructs(obj, field1Name, field1, field2Name, field2, tolerance, customTolerances, graphMismatchedData, compareStringFields, result);
                else
                    resultIndex = numel(result)+1;
                    result{resultIndex} = sprintf('''%s'' is a struct but ''%s'' is not.', field1Name, field2Name);
                end
          
            % compare strings
           elseif ischar(field1)
               if ischar(field2)
                   if (compareStringFields)
                       if (~strcmp(field1, field2))
                            resultIndex = numel(result)+1;
                            result{resultIndex} = sprintf('''%s'' and ''%s'' are different: ''%s'' vs. ''%s''.', field1Name, field2Name, field1, field2);
                       end
                   end
               else
                    resultIndex = numel(result)+1;
                    result{resultIndex} = sprintf('''%s'' is a char string but ''%s'' is not.\n', field1Name, field2Name);
               end
           
           % compare  numerics   
           elseif isnumeric(field1)
               if isnumeric(field2)
                   if (ndims(field1) ~= ndims(field2))
                       resultIndex = numel(result)+1;
                       result{resultIndex} = sprintf('''%s'' is a %d-D numeric whereas ''%s'' is a %d-D numeric.', field1Name, ndims(field1), field2Name, ndims(field2));
                   else 
                       if (any(size(field1)-size(field2)))
                            sizeField1String = sprintf((repmat('%2.0f  ', 1, numel(size(field1)))), size(field1));
                            sizeField2String = sprintf((repmat('%2.0f  ', 1, numel(size(field2)))), size(field2));
                            resultIndex = numel(result)+1;
                            result{resultIndex} = sprintf('''%s'' is a [%s] matrix whereas ''%s'' is a [%s] matrix.', field1Name, sizeField1String, field2Name, sizeField2String);
                       else
                           % equal size numerics
                           toleranceEmployed = 0.5*UnitTest.selectToleranceToEmploy(tolerance, customTolerances, field2Name);
                          
                           if (any(abs(field1(:)-field2(:)) > toleranceEmployed))
                                figureName = '';
                                if (graphMismatchedData)
                                    figureName = plotDataAndTheirDifference(obj, field1, field2, field1Name, field2Name);
                                end
                                resultIndex = numel(result)+1;
                                maxDiff = max(abs(field1(:)-field2(:)));
                                if (isempty(figureName))
                                    result{resultIndex} = sprintf('Max difference between ''%s'' and ''%s'' <strong>(%g)</strong> is greater than the set tolerance <strong>(%g)</strong>.', field1Name, field2Name, maxDiff, toleranceEmployed);
                                else
                                    result{resultIndex} = sprintf('Max difference between ''%s'' and ''%s'' <strong>(%g)</strong> is greater than the set tolerance <strong>(%g)</strong>. See figure named: ''%s''', field1Name, field2Name, maxDiff, toleranceEmployed, figureName);
                                end
                           end
                       end
                   end
               else
                   resultIndex = numel(result)+1;
                   result{resultIndex} = sprintf('''%s'' is a numeric but ''%s'' is not.', field1Name, field2Name);
               end
           
           % compare logicals
           elseif islogical(field1)
               if islogical(field2)
                   if (ndims(field1) ~= ndims(field2))
                       resultIndex = numel(result)+1;
                       result{resultIndex} = sprintf('''%s'' is a %d-D logical whereas ''%s'' is a %d-D logical.', field1Name, ndims(field1), field2Name, ndims(field2));
                   else 
                       if (any(size(field1)-size(field2)))

                       else
                           % equal size logicals
                           if (any(field1(:) ~= field2(:)))
                               resultIndex = numel(result)+1;
                               result{resultIndex} = sprintf('There are differences between logical fields''%s'' and ''%s''.', field1Name, field2Name);
                           end
                       end
                   end
               else
                   resultIndex = numel(result)+1;
                   result{resultIndex} = sprintf('''%s'' is a logical but ''%s'' is not.', field1Name, field2Name);
               end
           
           % compare cells
           elseif iscell(field1)
               if iscell(field2)
                   if (ndims(field1) ~= ndims(field2))
                       resultIndex = numel(result)+1;
                       result{resultIndex} = sprintf('''%s'' is a %d-D cell whereas ''%s'' is a %d-D cell.', field1Name, ndims(field1), field2Name, ndims(field2));
                   else 
                       if (any(size(field1)-size(field2)))
                            sizeField1String = sprintf((repmat('%2.0f  ', 1, numel(size(field1)))), size(field1));
                            sizeField2String = sprintf((repmat('%2.0f  ', 1, numel(size(field2)))), size(field2));
                            resultIndex = numel(result)+1;
                            result{resultIndex} = sprintf('''%s'' is a [%s] matrix whereas ''%s'' is a [%s] matrix.', field1Name, sizeField1String, field2Name, sizeField2String);
                       else
                            % equal size numerics
                            result = CompareCellArrays(obj, field1Name, field1, field2Name, field2, tolerance, customTolerances, graphMismatchedData, compareStringFields, result);
                       end
                   end
               else
                   resultIndex = numel(result)+1;
                   result{resultIndex} = sprintf('''%s'' is a cell but ''%s'' is not.', field1Name, field2Name);
               end
           
           % custom class, probably...
           elseif ((isobject(field1)) && (isobject(field2)))
                if (strcmp(class(field1), class(field2)))
                    % same class objects, convert them to structs
                    warning('off', 'MATLAB:structOnObject')
                    field1 = struct(field1);
                    field2 = struct(field2);
                    warning('on', 'MATLAB:structOnObject')
                    result = recursivelyCompareStructs(obj, field1Name, field1, field2Name, field2, tolerance, customTolerances, graphMismatchedData, compareStringFields, result);
                else
                    error('''%s'' and ''%s'' are different classes.',field1Name, field2Name);
                end
            else
                error('''%s'' and ''%s'' are not  compatible entities',field1Name, field2Name);
            end
        end  % for k
    end  % structIndex
    
end


function result = CompareCellArrays(obj, field1Name, field1, field2Name, field2, tolerance, customTolerances, graphMismatchedData, compareStringFields, result)

   for k = 1:numel(field1) 
       
       % Char values
       if (ischar(field1{k}))
           if (ischar(field2{k}))
               if (compareStringFields)
                   if (~strcmp(field1{k}, field2{k}))
                       resultIndex = numel(result)+1;
                       result{resultIndex} = sprintf('Corresponding cell fields have different string values: ''%s'' vs. ''%s''.', field1{k}, field2{k});
                   end
               end
           else
              resultIndex = numel(result)+1;
              result{resultIndex} = sprintf('Corresponding cell fields have different types');
           end
           
       % numeric values
       elseif (isnumeric(field1{k}))
           if (isnumeric(field2{k}))

               if (numel(field1) == 1) && (numel(field2) == 1)
                   toleranceEmployed = UnitTest.selectToleranceToEmploy(tolerance, customTolerances, field2Name);
                   if (abs(field1{1}-field2{1}) > toleranceEmployed)
                       resultIndex = numel(result)+1;
                       result{resultIndex} = sprintf('Corresponding cell fields have different numeric values: ''%g'' vs. ''%g''.', field1{1}, field2{1});
                   end
               else
                  subfield1 = field1{k};
                  subfield2 = field2{k};
                  if (any(size(subfield1)-size(subfield2)))
                      result{resultIndex} = sprintf('Corresponding cell subfields have different dimensionalities\n');
                  else
                      % equal size numerics
                      toleranceEmployed = 0.5*UnitTest.selectToleranceToEmploy(tolerance, customTolerances, field2Name);
                       
                      if (any(abs(subfield1(:)-subfield2(:)) > toleranceEmployed))
                            figureName = '';
                            if (graphMismatchedData)
                                figureName = plotDataAndTheirDifference(obj, subfield1, subfield2, field1Name, field2Name);
                            end
                            resultIndex = numel(result)+1;
                            maxDiff = max(abs(subfield1(:)-subfield2(:)));
                            if (isempty(figureName))
                                result{resultIndex} = sprintf('Max difference between ''%s'' and ''%s'' at index %d <strong>(%g)</strong> is greater than the set tolerance <strong>(%g)</strong>.', field1Name, field2Name, k, maxDiff, toleranceEmployed);
                            else
                                result{resultIndex} = sprintf('Max difference between ''%s'' and ''%s'' at index %d <strong>(%g)</strong> is greater than the set tolerance <strong>(%g)</strong>. See figure named: ''%s''', field1Name, field2Name, k, maxDiff, toleranceEmployed, figureName);
                            end
                       end
                  end
               end
           else
              resultIndex = numel(result)+1;
              result{resultIndex} = sprintf('Corresponding cell fields have different types');
           end
           
       % cells
       elseif (iscell(field1{k}))
           if (iscell(field2{k}))
               result = CompareCellArrays(obj, field1Name, field1{k}, field2Name, field2{k}, tolerance, customTolerances, graphMismatchedData, compareStringFields, result);
           else
              resultIndex = numel(result)+1;
              result{resultIndex} = sprintf('Corresponding cell fields have different types');
           end
           
        % structs
        elseif isstruct(field1{k})
           if isstruct(field2{k})
                result = recursivelyCompareStructs(obj, field1Name, field1{k}, field2Name, field2{k}, tolerance, customTolerances, graphMismatchedData, compareStringFields, result);
           else
                resultIndex = numel(result)+1;
                result{resultIndex} = sprintf('''%s'' is a struct but ''%s'' is not.', field1Name, field2Name);
           end
           
        % custom class, probably...
        elseif ((isobject(field1)) && (isobject(field2)))
            if (strcmp(class(field1), class(field2)))
                % same class objects, convert them to structs
                warning('off', 'MATLAB:structOnObject')
                field1 = struct(field1);
                field2 = struct(field2);
                warning('on', 'MATLAB:structOnObject')
                result = recursivelyCompareStructs(obj, field1Name, field1, field2Name, field2, tolerance, customTolerances, graphMismatchedData, compareStringFields, result);
            else
                error('''%s'' and ''%s'' are different classes.',field1Name, field2Name);
            end
        else
            error('''%s'' and ''%s'' are not  compatible entities',field1Name, field2Name);
        end
            
   end
end
