% Method to generate the directory path/subDir, if this directory does not exist
function directoryExistedAlready = generateDirectory(obj, path, subDir)
    fullDir = sprintf('%s/%s', path, subDir);
    directoryExistedAlready = true;
    
    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    projectSpecificPreferences = getpref(theProjectName, 'projectSpecificPreferences');
    
    if (projectSpecificPreferences.generateGroundTruthDataIfNotFound)
    if (~exist(fullDir, 'dir'))
        directoryExistedAlready = false;
        mkdir(fullDir);
    end
    end
end