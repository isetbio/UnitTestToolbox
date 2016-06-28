% Method to recursive round a struct
function s = roundStruct(oldStruct)

    s = oldStruct;
    
    if (isempty(s))
        return;
    end
    
    structFieldNames = fieldnames(s);
    for k = 1:numel(structFieldNames)
        
        % get field
        fieldValue = s.(structFieldNames{k});
        
        if isstruct(fieldValue)
            s.(structFieldNames{k}) = UnitTest.roundStruct(fieldValue);
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
            s.(structFieldNames{k}) = UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        elseif iscell(fieldValue)
            s.(structFieldNames{k}) = UnitTest.roundCellArray(fieldValue);
        elseif (islogical(fieldValue))
            s.(structFieldNames{k}) = fieldValue;
        else
            error('Do not know how to round param ''%s'', which is of  class type:''%s''. ', structFieldNames{k}, class(fieldValue));
        end
    end
    
end