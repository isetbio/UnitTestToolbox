% Method to query the user whether to really generate ground truth
% (only evoked if the validation data set is not found)
function [forceGenerateGroundTruth, cancelRun] = queryUserWhetherToReallyGenerateGroundTruth(obj, validationMode, scriptName)

    generateDataForAllScripts = upper('Yes, generate missing ground truth data.');
    donotGenerateData         = upper('No, I will email the ISETBIO team for the ground truth data.');
    quitRun                   = upper('Just cancel the entire run.');
    
    % Construct a questdlg with four options
    questionString = sprintf('Generate ''%s'' ground truth data set(s)?', validationMode);
    if (isempty(scriptName))
        headerString  = sprintf('ALERT: A ''%s'' ground truth data set directory was not found!', validationMode);
    else
        headerString  = sprintf('ALERT: A ''%s'' ground truth data set for script ''%s'' was not found!', validationMode, scriptName);
    end
    choice = questdlg(upper(questionString), ...
                      upper(headerString), ...
                      generateDataForAllScripts, donotGenerateData, quitRun, donotGenerateData);
                  
    % Handle response
    cancelRun = false;
    
    switch choice
        case quitRun
            forceGenerateGroundTruth = false;
            cancelRun = true;
            
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
