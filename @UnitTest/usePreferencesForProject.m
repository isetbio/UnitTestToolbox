% Method to select the preference group corresponding to the given project
function usePreferencesForProject(theProjectName, initMode)

    if ((nargin == 0) || (~ischar(theProjectName)))
        error('''UnitTest.usePreferencesForProject()'' requires a character string as its only argument');
    end
    
    setpref('UnitTest', 'projectName', theProjectName);
    fprintf('UnitTest will use preferences for the ''%s'' project\n', getpref('UnitTest', 'projectName'));

    if (ispref(theProjectName))
        fprintf('\nA set of existing preferences for project ''%s'' was found.\n',theProjectName);
    else
        fprintf('\nA set of existing preferences for project ''%s'' was *NOT* found.\n',theProjectName)
    end
    
    if (nargin == 1)
        initMode = 'none';
    end
    
    initializePrefs(initMode);
end

% Method to initalize prefs for the current project
function initializePrefs(initMode)

    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    if ispref(theProjectName, 'projectSpecificPreferences')
       projectSpecificPreferences = getpref(theProjectName, 'projectSpecificPreferences');
    else
       error('\nProjectSpecificPreferences do not exist for project ''%s''. Did you run the ''setProjectSpecificUnitTestPreferences.m'' script for ''%s''? \n', theProjectName,theProjectName); 
    end
    
    if (strcmp(initMode, 'reset'))
        rmpref(theProjectName);
    end
    
    if (~ispref(theProjectName, 'onRunTimeErrorBehavior'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'onRunTimeErrorBehavior'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref(theProjectName, 'onRunTimeErrorBehavior',  value); 
    end
    
    if (~ispref(theProjectName, 'generatePlots'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.runTimeOptionNames, 'generatePlots'));
        value = UnitTest.runTimeOptionDefaultValues{index};
        setpref(theProjectName, 'generatePlots',  value); 
    end
    
    if (~ispref(theProjectName, 'closeFigsOnInit'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.runTimeOptionNames, 'closeFigsOnInit'));
        value = UnitTest.runTimeOptionDefaultValues{index};
        setpref(theProjectName, 'closeFigsOnInit',  value); 
    end
    
    if (~ispref(theProjectName, 'verbosity'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'verbosity'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref(theProjectName, 'verbosity',  value); 
    end
    
    if (~ispref(theProjectName, 'numericTolerance'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'numericTolerance'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref(theProjectName, 'numericTolerance',  value); 
    end
   
    if (~ispref(theProjectName, 'graphMismatchedData'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'graphMismatchedData'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref(theProjectName, 'graphMismatchedData',  value); 
    end
    
    if (~ispref(theProjectName, 'compareStringFields'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'compareStringFields'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref(theProjectName, 'compareStringFields',  value); 
    end
    
    % Now the project-specific preferences
    setpref(theProjectName, 'projectSpecificPreferences', projectSpecificPreferences);
    
    preferenceNames = fieldnames(projectSpecificPreferences);
    for k = 1:numel(preferenceNames)
        thePreferenceName = preferenceNames{k};
        setpref(theProjectName, thePreferenceName,  projectSpecificPreferences.(thePreferenceName));
    end
    
    % restore the 'projectSpecificOptions'
    setpref(theProjectName, 'projectSpecificPreferences', projectSpecificPreferences);
end
