classdef UnitTest < handle
    % Class to handle unit tests for any project

    % Public properties (Read/write by all)
    properties

    end
    
    % Read-only public properties
    properties (SetAccess = private) 
        % Path to directory containing the @UnitTest class
        rootDir;
        
        % Path to directory where all HTML 'published' output will be
        % directed
        htmlDir;
        
        % Path to full validation data directory
        fullValidationDataDir;
        
        % Path to fast validation data directory
        fastValidationDataDir;
        
        % results of current validation session
        validationSessionRunTimeExceptions;
        
        % whether or not to use Remote Data Toolbox to get FULL data
        useRemoteDataToolbox;
        
        % configuration for Remote Data Toolbox
        remoteDataToolboxConfig;
        
        % summary report
        summaryReport;
    end
    
    % Private properties
    properties (Access = private)  
        % Struct with validation params
        defaultValidationParams;
        
        % Struct with validation params
        validationParams;
        
        % validation root directory: where the executive script lives
        validationRootDirectory;
        
        % List of scripts to validate. Each entry contains a cell array with a
        % script name and an optional params struct.
        vScriptsList = {};
        
        % map describing section organization (for github wiki)
        sectionData;
        
        % Starting figure number for figures showing mismatched data.
        % These figures should remain open
        dataMismatchFigNumber;
        
        % struct with various info on the host computer configuration
        hostInfo;
        
        % the matfile class was introduced in 2011b.
        % for compatibility with eariler versions of matlab
        % set useMatfile = false.
        useMatfile = false;
        
        % flag indicating whether to generate ground truth for all
        % remaining scripts with missing ground truth data
        % this is set after the user is queried for the first script
        % with a missing ground truth
        forceGenerateFastGroundTruthForAllScripts = false;
        forceGenerateFullGroundTruthForAllScripts = false;
    end
    
    % Constant properties. These are the only properties that can be
    % accessed by Static methods
    properties (Constant) 
        runTimeOptionNames              = {'generatePlots', 'closeFigsOnInit', 'printValidationReport'};
        runTimeOptionDefaultValues      = {false, true, false};
        
        validationOptionNames           = {'type',                ...
                                           'verbosity', ...
                                           'onRunTimeErrorBehavior', ...
                                           'numericTolerance', ...
                                           'graphMismatchedData', ...
                                           'compareStringFields', ...
                                           'validationRootDir', ...
                                           'clonedWikiLocation', ...
                                           'clonedGhPagesLocation', ...
                                           'githubRepoURL', ...
                                           };
                                       
        validationOptionDefaultValues   = {'RUNTIME_ERRORS_ONLY', ...
                                           'low', ...
                                           'rethrowExceptionAndAbort', ...
                                           500*eps, ...
                                           true,  ...
                                           false, ...
                                           '', ...
                                           '', ...
                                           '', ...
                                           '' ...
                                           };
        
        validValidationTypes            = {'RUNTIME_ERRORS_ONLY', 'FAST', 'FULL', 'FULLONLY', 'PUBLISH'};
        validOnRunTimeErrorValues       = {'rethrowExceptionAndAbort', 'catchExceptionAndContinue'};
        validVerbosityLevels            = {'absolute zero', 'none', 'min', 'low', 'med', 'high', 'max'};
        
        minFigureNoForMistmatchedData   = 10000;
        
        % number of decimal digits for rounding off data for hash computation 
        % we have found that when data are truncated to 12 decimal digits
        % the data hash keys across different computers are identical.
        % 13 and higher decimal digits lead to different hash keys
        decimalDigitNumRoundingForHashComputation = 9;
    end
    
    % Public methods (This is the public API)
    methods
        % Constructor
        function obj = UnitTest()           
            % Initialize the instantiated @UnitTest object
            obj.initializeUnitTest();
        end
        
        % Method to set certain validation options
        setValidationOptions(obj,varargin);
        
        % Method to reset all validation options to default
        resetValidationOptions(obj);
 
        % Main validation engine
        abortValidationSession = validate(obj,vScriptsList);
        
        % Method to push published HTML directories to github
        pushToGithub(obj, vScriptsList);
        
        % Method to query the user whether to really generate ground truth
        % (only evoked if the validation data set is not found)
        [forceGenerateGroundTruth, cancelRun] = queryUserWhetherToReallyGenerateGroundTruth(obj, validationMode, scriptName);
    end % public methods
    
    % Only the object itself can call these methods
    methods (Access = private)   
        
        % Method to generate the directory path/subDir, if this directory does not exist
        directoryExistedAlready = generateDirectory(obj, path, subDir);

        % Method ensuring that directories exist, and generates them if they do not
        abortValidationSession = checkDirectories(obj, projectSpecificPreferences);
        
        % Method to remove the root validationData directory
        removeValidationDataDir(obj);
        
        % Method to remove the root HTML directory
        removeHTMLDir(obj);
        
        % Method to parse the scripts list to ensure it is valid
        vScriptsList = parseScriptsList(obj, vScriptsToRunList);
    
        % Method to recursively compare two struct for equality
        [structsAreSimilarWithinSpecifiedTolerance, result, customToleranceFieldsArray] = structsAreSimilar(obj, groundTruthData, validationData, customTolerances);
        
        % Method to plot mistmatched validation data and their difference
        figureName = plotDataAndTheirDifference(obj, field1, field2, field1Name, field2Name);
        
        % Method to import a ground truth data entry
        [validationData, extraData, validationTime, hostInfo] = importGroundTruthData(obj, dataFileName);
        
        % Method to export a validation entry to a validation file
        exportData(obj, dataFileName, validationData, extraData);
        
        % Method to generate a hash0256 key based on the passed validationData
        hashSHA25 = generateSHA256Hash(obj,validationData);
        
        % Method to issue a git command with output capture
        issueGitCommand(obj, commandString);
    end
    
    
    % These methods can be called without instantiating an object first,
    % like so: UnitTest.methodName()
    methods (Static)
        % Method to remove all generated directories and files
        cleanUp();
        
        % Method to close all non-data mismatch figures
        closeAllNonDataMismatchFigures()
        
        % Executive method to run a validation session
        [obj, sessionAborted] = runValidationSession(vScriptsList, desiredMode, verbosity);
        
        % Method to select project-specific preferences 
        usePreferencesForProject(projectName, initMode);
        
        % Method to set a preference for the current project
        setPref(preferenceName, value);
        
        % Method to get a preference for the current project
        preferenceValue = getPref(preferenceName);
    
        % Method to list all the preferences for the current project
        listPrefs();
        
        % Method to publish a project's tutorials
        publishProjectTutorials(p, scriptsToSkip, scriptCollection)
        
        % Method to run a project's tutorials, testing but not publishing.
        status = runProjectTutorials(p, scriptsToSkip, scriptCollection)
        
        % Method to run a validation run.
        % Every validation script must call this method in its wrapper function
        varargout = runValidationRun(functionHandle, originalNargout, varargin);
        
        % Method to initalize a validation run.
        runTimeParams = initializeValidationRun(varargin);
        
        % Method to print what runtime options are available and their default values
        describeRunTimeOptions();
        
        % Method to print what validation options are available and their default values
        describeValidationOptions();
        
        % Method to append messages to the validationReport
        [report, validationFailedFlag, validationFundametalFailureFlag] = validationRecord(varargin);
        
        % Method to add new data to the validation data struct
        data = validationData(varargin);
        
        % Method to add new data to the validation data struct with custom
        % tolerances for specific subfields
        data = validationDataWithCustomTolerances(varargin);
    
        % Method to add new data to the extra data struct
        data = extraData(varargin);

        % Method to round numeric values to N decimal digits
        roundedValue = roundToNdigits(numericValue, decimalDigits);
        
        roundedValue = roundBeforeHashingGivenTolerance(numericValue, tolerance);
        
        % Method to print the validationReport
        printValidationReport(validationReport);
        
        % Method to display the nested structures
        s = displayNicelyFormattedStruct(datum, datumName, s, maxFieldWidth);
        
        % Method that prints all available validation scripts and asks the
        % user to select one for validation.
        scriptToValidate = selectScriptFromExistingOnes(varargin);
        
        % Method to select which tolerance to employ by checking if the
        % fieldName exists in customTolerances
        [toleranceEmployed, isCustom] = selectToleranceToEmploy(globalTolerance, customTolerances, fieldName);
        
        % Method to recursively round a cellArray
        cellArray = roundCellArray(oldCellArray);
    
        % Method to recursively round a struct
        s = roundStruct(oldStruct);
    
        % Method to recursively round a struct (alternative to roundStruct)
        s = roundStructGivenTolerance(oldStruct, structName, globalTolerance, customTolerances)
        
        % Method to recursively round a cellArray (alternative to roundCellArray)
        cellArray = roundCellArrayGivenTolerance(fieldValue, fieldName, globalTolerance, customTolerances);
        
        % Method to implement an assert statement for things that should be
        % almost the same.
        assertIsZero(expression,msgString,tolerance);
        
        % Method to implement an assert statement for things that should be true
        assert(expression,msgString);
    end
end
