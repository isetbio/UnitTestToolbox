% Method to initalize prefs for the current project
function initializePrefs(initMode)

    if (nargin == 0)
        initMode = 'none';
    end
    
    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    if ispref(theProjectName, 'projectSpecificOptions')
       projectSpecificOptions = getpref(theProjectName, 'projectSpecificOptions');
    else
       error('\nProjectSpecificOptions do not exist for project ''%s''. Did you run the ''setProjectSpecificUnitTestPreferences.m'' script for ''%s''? \n', theProjectName,theProjectName); 
    end
    
    if (strcmp(initMode, 'reset'))
        rmpref(theProjectName);
    end
    
    if ~(ispref(theProjectName, 'updateGroundTruth')) || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'updateGroundTruth'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref(theProjectName, 'updateGroundTruth', value);
    end
    
    if ~(ispref(theProjectName, 'updateValidationHistory'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'updateValidationHistory'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref(theProjectName, 'updateValidationHistory', value);
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
    preferenceNames = fieldnames(projectSpecificOptions);
    for k = 1:numel(preferenceNames)
        thePreferenceName = preferenceNames{k};
        setpref(theProjectName, thePreferenceName,  projectSpecificOptions.(thePreferenceName));
    end
    
    % restore the 'projectSpecificOptions'
    setpref(theProjectName, 'projectSpecificOptions', projectSpecificOptions);
    
end
