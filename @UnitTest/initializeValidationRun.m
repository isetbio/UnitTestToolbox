function runTimeParams = initializeValidationRun(varargin)  
    % Initialize run params
    runTimeParams = initializeRunTimeParams(varargin);
    
    % Initialize validation record
    UnitTest.validationRecord('command', 'init');  
   
    % Initialize validationData
    UnitTest.validationData('command', 'init');
    
    % Initialize extraData
    UnitTest.extraData('command', 'init');
end

function runParams = initializeRunTimeParams(varargin)
        
    for k = 1:numel(UnitTest.runTimeOptionNames)
       eval(sprintf('defaultParams.%s = UnitTest.runTimeOptionDefaultValues{k};', UnitTest.runTimeOptionNames{k}));
    end
    
    if (getpref('UnitTest', 'inStandAloneMode') == false)
        assert(nargin == 1);
        
        runParamsPassed = varargin{1};
        runParamsPassed = runParamsPassed{1};
        while (iscell(runParamsPassed{1}) && (~isempty(runParamsPassed{1})))
            runParamsPassed = runParamsPassed{1};
        end
        
        if (isempty(runParamsPassed{1}))
            runParams = defaultParams;
            % Get current project name
            theProjectName = getpref('UnitTest', 'projectName');
            runParams.generatePlots   = getpref(theProjectName, 'generatePlots');
            runParams.closeFigsOnInit = getpref(theProjectName, 'closeFigsOnInit');
            runParams.inStandAloneMode = false;
            if (runParams.closeFigsOnInit)
                UnitTest.closeAllNonDataMismatchFigures();
            end
            return;
        end
        
        runParamsPassed = runParamsPassed{1};

        % Make sure passed argument is a struct
        assert(isstruct(runParamsPassed));
        
        % start with default params
        runParams = defaultParams;
        
        % Make sure the struct field names are what we expect, and modify
        % the runParams accordingly
        runParamStructFields = fieldnames(runParamsPassed);
        if ~isempty(runParamStructFields)
            for k = 1:numel(runParamStructFields)
                if (~ismember(runParamStructFields{k}, UnitTest.runTimeOptionNames))
                    error('Unknown runParams fieldname: ''%s''', runParamStructFields{k});
                else
                    eval(sprintf('runParams.%s = runParamsPassed.%s;', runParamStructFields{k}, runParamStructFields{k}));
                end
            end
        end
        runParams.inStandAloneMode = false;
    else
       % Script is run in stand-alone mode, not from a
       % UnitTest validation session, or when no argument is passed
       runParams = defaultParams; 
       runParams.printValidationReport  = true;
       runParams.generatePlots          = true;
       runParams.closeFigsOnInit        = false;
       runParams.inStandAloneMode       = true;
    end 
    
    if (runParams.closeFigsOnInit)
       UnitTest.closeAllNonDataMismatchFigures();
    end
end
