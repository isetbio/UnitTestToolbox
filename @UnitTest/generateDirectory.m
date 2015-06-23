% Method to generate the directory path/subDir, if this directory does not exist
function directoryExistedAlready = generateDirectory(obj, path, subDir)
    fullDir = sprintf('%s/%s', path, subDir);
    directoryExistedAlready = true;
    
    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    projectSpecificPreferences = getpref(theProjectName, 'projectSpecificPreferences');
    
    if (projectSpecificPreferences.generateGroundTruthDataIfNotFound)
        if (~exist(fullDir, 'dir'))
            if (validationParams.verbosity > 4)
                fprintf('\nDirectory\n\t%s\n does not exist. Will create it. Hit enter to continue');
                pause;
            end
            
            directoryExistedAlready = false;
            mkdir(fullDir);
        end
    end
end