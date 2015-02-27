% Method to query the user whether to really generate ground truth
% (only evoked if the validation data set is not found)
function forceGenerateGroundTruth = queryUserWhetherToReallyGenerateGroundTruth(obj, validationMode, scriptName)

    generateDataForThisScript = upper('Yes, for this script *only*.');
    generateDataForAllScripts = upper('Yes, for this *and* any other scripts with missing data.');
    donotGenerateData         = upper('No, I will email the ISETBIO team for the ground truth data.');
    
    % Construct a questdlg with four options
    questionString = sprintf('Generate ''%s'' ground truth data set(s)?', validationMode);
    headerString  = sprintf('ALERT: A ''%s'' ground truth data set for script ''%s'' was not found!', validationMode, scriptName);
    choice = questdlg(upper(questionString), ...
                      upper(headerString), ...
                      generateDataForThisScript, generateDataForAllScripts, donotGenerateData, donotGenerateData);
                  
    % Handle response
    switch choice
        case generateDataForThisScript
            forceGenerateGroundTruth = true;
            if (strcmp(validationMode, 'FAST'))
                obj.forceGenerateFastGroundTruthForAllScripts = false;
            end
            if (strcmp(validationMode, 'FULL'))
                obj.forceGenerateFullGroundTruthForAllScripts = false;
            end
            
        case generateDataForAllScripts
            forceGenerateGroundTruth = true;
            if (strcmp(validationMode, 'FAST'))
                obj.forceGenerateFastGroundTruthForAllScripts = true;
            end
            if (strcmp(validationMode, 'FULL'))
                obj.forceGenerateFullGroundTruthForAllScripts = true;
            end
            
        case donotGenerateData
            forceGenerateGroundTruth = false;
            if (strcmp(validationMode, 'FAST'))
                obj.forceGenerateFastGroundTruthForAllScripts = false;
            end
            if (strcmp(validationMode, 'FULL'))
                obj.forceGenerateFullGroundTruthForAllScripts = false;
            end
            
            h = warndlg(upper('Validation data sets are available by the ISETBIO team.'),...
                upper('email cottaris@sas.upenn.edu '));
            uiwait(h);
    end
    
end
