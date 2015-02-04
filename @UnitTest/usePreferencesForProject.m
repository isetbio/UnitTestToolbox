% Method to select the preference group corresponding to the given project
function usePreferencesForProject(theProjectName)

    if ((nargin ~= 1) || (~ischar(theProjectName)))
        error('''UnitTest.usePreferencesForProject()'' requires a character string as its only argument');
        return;
    end
    
    setpref('UnitTest', 'projectName', theProjectName);
    fprintf('UnitTest will use preferences for the ''%s'' project\n', getpref('UnitTest', 'projectName'));

    if (ispref(theProjectName))
        fprintf('\nA set of existing preferences for project ''%s'' was found.\n',theProjectName);
    else
        fprintf('\nA set of existing preferences for project ''%s'' was *NOT* found.\n',theProjectName)
    end
end
