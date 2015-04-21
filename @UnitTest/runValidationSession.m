function runValidationSession(vScriptsList, desiredMode)

    if (nargin == 1)
        fprintf('\nAvailable validation modes:');
        fprintf('\n\t 1. FASTEST (runtime errors only)');
        fprintf('\n\t 2. FAST    (runtime errors + data hash comparison)');
        fprintf('\n\t 3. FULL    (runtime errors + full data comparison)');
        fprintf('\n\t 4. PUBLISH (runtime errors + full data comparison + github wiki update)');
        typeID = input('\nEnter validation run mode [default = 1]: ', 's');
        if (str2double(typeID) == 1)
            desiredMode = 'RUN_TIME_ERRORS_ONLY';
        elseif (str2double(typeID) == 2)
            desiredMode = 'FAST';
        elseif (str2double(typeID) == 3)
            desiredMode = 'FULL';
        elseif (str2double(typeID) == 4)
            desiredMode = 'PUBLISH';
        else
            desiredMode = 'RUN_TIME_ERRORS_ONLY';
        end
    end
    
    if (strcmp(desiredMode, 'RUN_TIME_ERRORS_ONLY'))
        validateRunTimeErrors(vScriptsList);
        
    elseif (strcmp(desiredMode, 'FAST'))
        validateFast(vScriptsList);
        
    elseif (strcmp(desiredMode, 'FULL'))
        validateFull(vScriptsList);
        
    elseif (strcmp(desiredMode, 'PUBLISH'))
        validatePublish(vScriptsList);
        
    else
        fprintf('Invalid selection. Run again.\n');
        return;
    end
end

function validateRunTimeErrors(vScriptsList)
    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();
        
    % Print the available validation options and their default values
    % UnitTest.describeValidationOptions();
    
    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    
    % Set options for RUNTIME_ERRORS_ONLY validation
    UnitTestOBJ.setValidationOptions(...
                'type',                     'RUNTIME_ERRORS_ONLY', ...
                'onRunTimeError',           getpref(theProjectName, 'onRunTimeErrorBehavior') ...
                );
            
    % ... and Go ! 
    abortValidationSession = UnitTestOBJ.validate(vScriptsList);
end


function validateFast(vScriptsList)

    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();   
    
    % Print the available validation options and their default values
    % UnitTest.describeValidationOptions();
    
    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    
    % Set options for FAST validation
    UnitTestOBJ.setValidationOptions(...
                'type',                     'FAST', ...
                'onRunTimeError',           getpref(theProjectName, 'onRunTimeErrorBehavior') ...
                );
            
    % ... and Go ! 
    [abortValidationSession, vScriptsListWithNewFastValidationDataSet] = UnitTestOBJ.validate(vScriptsList);
    
    % Pass 2: Update FULL validation data sets for scripts with new FAST validation data sets
    if (~isempty(vScriptsListWithNewFastValidationDataSet))
        % Instantiate another @UnitTest object
        UnitTestOBJ2 = UnitTest();   
    
        % Set options for FULL validation
        UnitTestOBJ2.setValidationOptions(...
                'type',                     'FULL', ...
                'onRunTimeError',           getpref(theProjectName, 'onRunTimeErrorBehavior') ...
                );
            
        % ... and Go ! 
        fprintf('\nPASS 2: generating FULL Validation data sets for scripts with updated FAST validation data sets.\n');
        [abortValidationSession, ~] = UnitTestOBJ2.validate(vScriptsListWithNewFastValidationDataSet);
    end
        
end

function validateFull(vScriptsList)
    
    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();
    
    % Print the available validation options and their default values
    % UnitTest.describeValidationOptions();
    
    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    
    % Set options for FULL validation
    UnitTestOBJ.setValidationOptions(...
                'type',                     'FULL', ...
                'onRunTimeError',           getpref(theProjectName, 'onRunTimeErrorBehavior') ...
                );
    
    % ... and Go ! 
    [abortValidationSession, vScriptsListWithNewFullValidationDataSet] = UnitTestOBJ.validate(vScriptsList);
    
    % Pass 2: Update FAST validation data sets for scripts with new FULL validation data sets
    if (~isempty(vScriptsListWithNewFullValidationDataSet))
        % Instantiate another @UnitTest object
        UnitTestOBJ2 = UnitTest();   
    
        % Set options for FAST validation
        UnitTestOBJ2.setValidationOptions(...
                'type',                     'FAST', ...
                'onRunTimeError',           getpref(theProjectName, 'onRunTimeErrorBehavior') ...
                );
            
        % ... and Go ! 
        fprintf('\nPASS 2: generating FAST Validation data sets for %d scripts with updated FULL validation data sets.\n', numel(vScriptsListWithNewFullValidationDataSet));
        [abortValidationSession, ~] = UnitTestOBJ2.validate(vScriptsListWithNewFullValidationDataSet);
    end
end


function validatePublish(vScriptsList)

    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();
    
    % Cleanup HTML directory if it exists
    UnitTestOBJ.removeHTMLDir();
    
    % Print the available validation options and their default values
    % UnitTest.describeValidationOptions();
    
     % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    
    % Set options for PUBLISH validation
    UnitTestOBJ.setValidationOptions(...
                'type',                     'PUBLISH', ...
                'onRunTimeError',           getpref(theProjectName, 'onRunTimeErrorBehavior') ... 
                );
            
    % ... and Go ! 
    [abortValidationSession, vScriptsListWithNewFullValidationDataSet] = UnitTestOBJ.validate(vScriptsList);     
    
    % Pass 2: Update FAST validation data sets for scripts with new FULL validation data sets
    if (~isempty(vScriptsListWithNewFullValidationDataSet))
        % Instantiate another @UnitTest object
        UnitTestOBJ2 = UnitTest();   
    
        % Set options for FAST validation
        UnitTestOBJ2.setValidationOptions(...
                'type',                     'FAST', ...
                'onRunTimeError',           getpref(theProjectName, 'onRunTimeErrorBehavior') ...
                );
            
        % ... and Go ! 
        fprintf('\nPASS 2: generating FAST Validation data sets for %d scripts which have updated FULL validation data sets.\n', numel(vScriptsListWithNewFullValidationDataSet));
        [abortValidationSession, ~] = UnitTestOBJ2.validate(vScriptsListWithNewFullValidationDataSet);
    end
    
    
    if (abortValidationSession == false)
        % Push published HTML directories to github
        UnitTestOBJ.pushToGithub(vScriptsList);
    end
    
    % Remove HTML directories
    UnitTestOBJ.removeHTMLDir();
end
