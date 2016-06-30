% Method to recursively round a cellArray (alternative to roundCellArray)
function cellArray = roundCellArrayGivenTolerance(oldCellArray, fieldName, globalTolerance, customTolerances)
    cellArray = oldCellArray;
    
    for k = 1:numel(cellArray)
        
        % get field 
        fieldValue = cellArray{k};
        
        % Char values
        if ischar(fieldValue)
            % Get current project name
            theProjectName = getpref('UnitTest', 'projectName');
            compareStringFields = getpref(theProjectName, 'compareStringFields');
            if (compareStringFields)
            else
                cellArray{k} = '';
                %fprintf('NOT ADDING CHAR FIELD TO HASH DATA'); 
            end
             
        % Numeric values
        elseif (isnumeric(fieldValue))
            toleranceEmployed = UnitTest.selectToleranceToEmploy(globalTolerance, customTolerances, fieldName);
            cellArray{k} = UnitTest.roundBeforeHashingGivenTolerance(fieldValue, toleranceEmployed); %UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        
        % Cells
        elseif (iscell(fieldValue))
            cellArray{k} = UnitTest.roundCellArrayGivenTolerance(fieldValue, fieldName, globalTolerance, customTolerances); % UnitTest.roundCellArray(fieldValue);
            
        % Logical
        elseif (islogical(fieldValue))
            cellArray{k} = fieldValue;
            
        % Struct
         elseif (isstruct(fieldValue))
             cellArray{k} = UnitTest.roundStructGivenTolerance(fieldValue, fieldName, globalTolerance, customTolerances); % UnitTest.roundStruct(fieldValue);
            
        else
            error('Do not know how to round cell entry (''%s'') which is of class type:''%s''. ',  fieldName, class(fieldValue));
        end
    end
end
