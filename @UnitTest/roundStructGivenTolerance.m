% Method to recursive round a struct
function s = roundStructGivenTolerance(oldStruct, structName, globalTolerance, customTolerances)

    s = oldStruct;
    
    if (isempty(s))
        return;
    end
    
    structFieldNames = fieldnames(s);
    for k = 1:numel(structFieldNames)
        
        % get field
        fieldValue = s.(structFieldNames{k});
        
        if isstruct(fieldValue)
            s.(structFieldNames{k}) = UnitTest.roundStructGivenTolerance(fieldValue, sprintf('%s.%s', structName, structFieldNames{k}), globalTolerance, customTolerances);
        elseif ischar(fieldValue)
            % Get current project name
            theProjectName = getpref('UnitTest', 'projectName');
            compareStringFields = getpref(theProjectName, 'compareStringFields');
            if (compareStringFields)
                %fprintf('ADDING CHAR FIELD %s TO HASH DATA', structFieldNames{k}); 
            else
                s.(structFieldNames{k}) = '';
                %fprintf('NOT ADDING CHAR FIELD %s TO HASH DATA', structFieldNames{k}); 
            end
        elseif isnumeric(fieldValue)
            toleranceEmployed = UnitTest.selectToleranceToEmploy(globalTolerance, customTolerances, sprintf('%s.%s', structName, structFieldNames{k}));
            s.(structFieldNames{k}) = UnitTest.roundBeforeHashingGivenTolerance(fieldValue, toleranceEmployed); % UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        elseif iscell(fieldValue)
            s.(structFieldNames{k}) = UnitTest.roundCellArrayGivenTolerance(fieldValue, globalTolerance, customTolerances);
        elseif (islogical(fieldValue))
            s.(structFieldNames{k}) = fieldValue;
        else
            error('Do not know how to round param ''%s'', which is of  class type:''%s''. ', sprintf('%s.%s', structName, structFieldNames{k}), class(fieldValue));
        end
    end
    
end