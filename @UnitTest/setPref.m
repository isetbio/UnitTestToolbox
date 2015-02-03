% Method to set a preference for the current project
function setPref(preferenceName, value)

    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    
    if ~(ispref(theProjectName, preferenceName))
        error('''%s is not a valid preference name', preferenceName);
    end
    
    if ( (strcmp(preferenceName, 'updateValidationHistory')) || ...
         (strcmp(preferenceName, 'updateGroundTruth')) || ...
         (strcmp(preferenceName, 'generatePlots')) || ...
         (strcmp(preferenceName, 'graphMismatchedData')) || ...
         (strcmp(preferenceName, 'compareStrings')) )
            if (~islogical(value))
                error('''%s'' preference value must be set to true or false (logical)', preferenceName);
            end
    end
    
    if (strcmp(preferenceName, 'onRunTimeErrorBehavior'))
        if (~ischar(value))
            error('''onRunTimeErrorBehavior'' preference must be a character string');
        end
        if ~ismember(value, UnitTest.validOnRunTimeErrorValues)
            eval('validOnRunTimeErrorValues = UnitTest.validOnRunTimeErrorValues');
            error('Cannot set ''%s'' to ''%s''. Invalid option.', preferenceName, value);
        end
    end
    
    if (strcmp(preferenceName, 'verbosity'))
        if (~ischar(value))
            error('''verbosity'' preference must be a character string');
        end
        if ~ismember(value, UnitTest.validVerbosityLevels)
            eval('validVerbosityValues = UnitTest.validVerbosityLevels');
            error('Cannot set ''%s'' to ''%s''. Invalid option.', preferenceName, value);
        end
    end
    
    setpref(theProjectName, preferenceName, value);
end
