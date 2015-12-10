% Method to generate the directory path/subDir, if this directory does not exist
function directoryExistedAlready = generateDirectory(obj, path, subDir)
    fullDir = sprintf('%s/%s', path, subDir);
    directoryExistedAlready = true;
    
    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    projectSpecificPreferences = getpref(theProjectName, 'projectSpecificPreferences');
    
    validationParams = obj.validationParams;
    
    if (projectSpecificPreferences.generateGroundTruthDataIfNotFound)
        if (~exist(fullDir, 'dir')) && ~obj.useRemoteDataToolbox
            if (validationParams.verbosity > 4)
                fprintf(2,'\nDirectory\n\t%s\n does not exist. Will create it. Hit enter to continue', fullDir);
                pause;
            end
            
            directoryExistedAlready = false;
            try
                mkdir(fullDir);
            catch err
                fprintf('\n --------------------------------------------------------------------------------------\n');
                fprintf('\n Failed to generate directory ''%s''. Check path and privileges and retry.\n', fullDir);
                fprintf('\n --------------------------------------------------------------------------------------\n\n')
                rethrow(err);
            end
        end
    end
end