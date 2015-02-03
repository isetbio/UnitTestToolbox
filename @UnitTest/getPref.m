% Method to get a preference for the current project
function preferenceValue = getPref(preferenceName)

    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    
    % Return the preference value
    preferenceValue = getpref(theProjectName, preferenceName);
end

