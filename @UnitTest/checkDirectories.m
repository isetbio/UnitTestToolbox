% Method ensuring that directories exist, and generates them if they do not
function cancelRun = checkDirectories(obj, projectSpecificPreferences)

    cancelRun = false;
    
    % do not automatically generate ground truth for all scripts with missing ground truth data set
    obj.forceGenerateFastGroundTruthForAllScripts = false;
    obj.forceGenerateFullGroundTruthForAllScripts = false;
    
    % Check if HTML directory exists and create it, if it does not exist
    if (strcmp(obj.validationParams.type, 'PUBLISH'))
        if (~exist(obj.htmlDir, 'dir'))
            mkdir(obj.htmlDir); 
        end
        addpath(obj.htmlDir);
    end
    
    % Check if validationData directory exists and create it, if it does not exist
    if ~(strcmp(obj.validationParams.type, 'RUNTIME_ERRORS_ONLY'))
  
        if  (strcmp(obj.validationParams.type, 'FULL')) || (strcmp(obj.validationParams.type, 'PUBLISH'))
             if (~exist(obj.fullValidationDataDir, 'dir'))
                if (projectSpecificPreferences.generateGroundTruthDataIfNotFound)
                    [generateDir, cancelRun] = obj.queryUserWhetherToReallyGenerateGroundTruth(obj.validationParams.type, []);
                    if (generateDir)
                        mkdir(obj.fullValidationDataDir);
                    end
                end
             end
             addpath(obj.fullValidationDataDir);
        end
        
        if (cancelRun == false)
            if  (strcmp(obj.validationParams.type, 'FAST')) || (strcmp(obj.validationParams.type, 'PUBLISH'))
                if (~exist(obj.fastValidationDataDir, 'dir'))
                    if (projectSpecificPreferences.generateGroundTruthDataIfNotFound)
                        [generateDir, cancelRun] = obj.queryUserWhetherToReallyGenerateGroundTruth(obj.validationParams.type, []);
                        if (generateDir)
                            mkdir(obj.fastValidationDataDir);
                        end
                    end
                end
                addpath(obj.fastValidationDataDir);
            end
        end
        
    end
end




    