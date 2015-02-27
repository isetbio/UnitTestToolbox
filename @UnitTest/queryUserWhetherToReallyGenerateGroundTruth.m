% Method to query the user whether to really generate ground truth
% (only evoked if the validation data set is not found)
function forceGenerateGroundTruth = queryUserWhetherToReallyGenerateGroundTruth(obj, validationMode, scriptName)

    generateString = upper('Yes, I know what I am doing!');
    donotGenerateString = upper('Ooops... No, please do not generate the ground truth data.');
    
    % Construct a questdlg with three options
    questionString = sprintf('Generate ''%s'' ground truth data set for this script?', validationMode);
    headerString  = sprintf('ALERT: A ''%s'' ground truth data set for script ''%s'' was not found!', validationMode, scriptName);
    choice = questdlg(upper(questionString), ...
                      upper(headerString), ...
                      generateString, donotGenerateString, donotGenerateString);
                  
    % Handle response
    switch choice
        case generateString
            forceGenerateGroundTruth = true;
        
        case donotGenerateString
            forceGenerateGroundTruth = false;
    end
    
    
    if (forceGenerateGroundTruth)
        repeatForAllString = upper('Yes, generate ground truth for all remaining scripts and don''t ask me again!');
        doNotRepeatForAllString = upper('No, ask me separately for every script.');
    
        % Construct a questdlg with three options
        headerString = sprintf('Generate ''%s'' ground truth data for all remaining scripts that do not have a ground truth ?', validationMode);
        choice = questdlg('', ...
                          upper(headerString), ...
                          repeatForAllString, doNotRepeatForAllString, doNotRepeatForAllString);
                      
        % Handle response
        switch choice
            case repeatForAllString
                if (strcmp(validationMode, 'FAST'))
                    obj.forceGenerateFastGroundTruthForAllScripts = true;
                end
                if (strcmp(validationMode, 'FULL'))
                    obj.forceGenerateFullGroundTruthForAllScripts = true;
                end

            case doNotRepeatForAllString
                if (strcmp(validationMode, 'FAST'))
                    obj.forceGenerateFastGroundTruthForAllScripts = false;
                end
                if (strcmp(validationMode, 'FULL'))
                    obj.forceGenerateFullGroundTruthForAllScripts = false;
                end
                
        end
    
    end
    
end
