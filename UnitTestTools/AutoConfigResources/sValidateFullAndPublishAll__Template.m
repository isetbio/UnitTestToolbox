function prefixValidateFullAndPublishAll
%
% Validation and publish our full list of validation programs

    close all
    clc
    
    %% We will use preferences for the project at hand
    UnitTest.usePreferencesForProject('xxyyzzprojectname', 'reset');

    %% Set some preferences:
    
    %% Run time error behavior
    % valid options are: 'rethrowExceptionAndAbort', 'catchExceptionAndContinue'
    UnitTest.setPref('onRunTimeErrorBehavior', 'catchExceptionAndContinue');
    
    %% Plot generation
    UnitTest.setPref('generatePlots',  true); 
    UnitTest.setPref('closeFigsOnInit', true);
    
    %% Verbosity Level
    % valid options are: 'none', min', 'low', 'med', 'high', 'max'
    UnitTest.setPref('verbosity', 'med');
    
    %% Numeric tolerance for comparison to ground truth data
    UnitTest.setPref('numericTolerance', 500*eps);
    
    %% Whether to plot data that do not agree with the ground truth
    UnitTest.setPref('graphMismatchedData', false);
    
    %% Print current values of prefs
    UnitTest.listPrefs();
    
    %% What to validate
    listingScript = UnitTest.getPref('listingScript');
    vScriptsList = eval(listingScript);
        
    %% How to validate
    % Run a RUN_TIME_ERRORS_ONLY validation session
    % UnitTest.runValidationSession(vScriptsList, 'RUN_TIME_ERRORS_ONLY')
    
    % Run a FAST validation session (comparing SHA-256 hash keys of the data)
    % UnitTest.runValidationSession(vScriptsList, 'FAST');
    
    % Run a FULL validation session (comparing actual data)
    % UnitTest.runValidationSession(vScriptsList, 'FULL');
    
    % Run a PUBLISH validation session (comparing actual data and update github wiki)
    UnitTest.runValidationSession(vScriptsList, 'PUBLISH');
    
    % Run a validation session without a specified mode. You will be
    % promped to select one of the available modes.
    % UnitTest.runValidationSession(vScriptsList);

end