% Method to recursively round a cellArray
function cellArray = roundCellArray(oldCellArray)
    cellArray = oldCellArray;
    
    for k = 1:numel(cellArray)
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
            cellArray{k} = UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        
        % Cells
        elseif (iscell(fieldValue))
            cellArray{k} = UnitTest.roundCellArray(fieldValue);
            
        % Logical
        elseif (islogical(fieldValue))
            cellArray{k} = fieldValue;
            
        % Struct
         elseif (isstruct(fieldValue))
             cellArray{k} = UnitTest.roundStruct(fieldValue);
            
        else
            error('Do not know how to round cell entry which is of class type:''%s''. ',  class(fieldValue));
        end
    end
end

    