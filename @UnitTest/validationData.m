% Method to add new data to the validation data struct
function data = validationData(varargin)
    
    persistent validationData
    
    data = [];
    
    if ischar(varargin{1}) && ischar(varargin{2}) && (strcmp(varargin{1}, 'command')) && (strcmp(varargin{2}, 'init'))
        validationData = struct();
        return;
    end
    
    if ischar(varargin{1}) && ischar(varargin{2}) && (strcmp(varargin{1}, 'command')) && (strcmp(varargin{2}, 'return'))
        data = validationData;
        return;
    end
    
    if (getpref('UnitTest', 'inStandAloneMode'))
        % this is the case when we run in stand-alone mode, so we do not
        % want to do anything else here
        return;
    end
    
    % Get field name and its value
    fieldName = varargin{1};
    fieldValue = varargin{2};
    % make sure field does not already exist in the validationData struct
    if ismember(fieldName, fieldnames(validationData))
        fprintf(2,'\tField ''%s'' already exists in the validationData struct. Its value will be overriden.\n', fieldName);
    end
        
    
    % Parse optional custom variable-tolerance pairs
    customTolerances = struct();
    
    if (numel(varargin)>2)
        if (strcmp(varargin{3}, 'UsingTheFollowingVariableTolerancePairs'))
            if (mod(numel(varargin(4:end)),2) == 1)
                error('Number of custom tolerance input arguments in UnitTest.validationDataWithCustomTolerances() must be even (key-value pairs)');
            end

            % Parse any passed custom tolerances
            for k = 4:2:numel(varargin)
                subfieldName = varargin{k};
                subfieldTolerance = varargin{k+1};
                if (strfind(subfieldName, '.'))
                    subfieldName = strrep(subfieldName, sprintf('%s.', fieldName), '');
                    eval(sprintf('customTolerances.%s = subfieldTolerance;', subfieldName));
                else
                    customTolerances = subfieldTolerance;
                end
            end
            validationData.customTolerances.(fieldName) = customTolerances;
        else
            error('To specify custom tolerances, the third variable in UnitTest.validationData() must be the string ''UsingTheFollowingVariableTolerancePairs''. ');
        end
    end
    
    if (~isfield(validationData, 'customTolerances'))
        validationData.customTolerances = [];
    end
    
    % save the full data
    validationData.(fieldName) = fieldValue;

    globalTolerance = 10^(-UnitTest.decimalDigitNumRoundingForHashComputation);
 
   
    % save truncated data in hashData.(fieldName)
    if (isnumeric(fieldValue))
        toleranceEmployed = UnitTest.selectToleranceToEmploy(globalTolerance, validationData.customTolerances, fieldName);
        validationData.hashData.(fieldName) = UnitTest.roundBeforeHashingGivenTolerance(fieldValue, toleranceEmployed); %UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
    elseif (isstruct(fieldValue))
        validationData.hashData.(fieldName) = UnitTest.roundStructGivenTolerance(fieldValue, fieldName, globalTolerance, validationData.customTolerances);  % UnitTest.roundStruct(fieldValue);
    elseif (iscell(fieldValue))
        validationData.hashData.(fieldName) = UnitTest.roundCellArrayGivenTolerance(fieldValue, fieldName, globalTolerance, validationData.customTolerances); % UnitTest.roundCellArray(fieldValue);
    elseif (ischar(fieldValue))
        % only add string field if we are comparing them
        % get current project name
        theProjectName = getpref('UnitTest', 'projectName');
        compareStringFields = getpref(theProjectName, 'compareStringFields');
        if (compareStringFields)
            validationData.hashData.(fieldName) = fieldValue;
            %fprintf('ADDING CHAR FIELD %s TO HASH DATA', fieldName); 
        else
            validationData.hashData.(fieldName) = '';
            %fprintf('NOT ADDING CHAR FIELD %s TO HASH DATA', fieldName); 
        end
    elseif (islogical(fieldValue))
        validationData.hashData.(fieldName) = fieldValue;
    else
        error('Do not know how to round param ''%s'', which is of  class type:''%s''. ', fieldName, class(fieldValue));
        %validationData.hashData.(fieldName) = fieldValue;
    end
end