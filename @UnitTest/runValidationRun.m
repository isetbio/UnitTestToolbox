function returnItems = runValidationRun(functionHandle, originalNargout, varargin)
    
    %% Parse varargin to determine whether the script is run in stand-alone mode.
    original_varargin = varargin;
    k = 0;
    while (iscell(original_varargin)) && (numel(original_varargin)>0)
       original_varargin = original_varargin{1};
       k = k + 1;
    end
    original_nargin = k-1;
    
    %% Set the UnitTest preference 'inStandAloneMode'
    if (original_nargin > 0)
        % script is managed by a @UnitTest object
        setpref('UnitTest', 'inStandAloneMode', false);
    else
        % script is running in stand-alone mode
        setpref('UnitTest', 'inStandAloneMode', true);
    end
    
    %% Initialize validation run
    runTimeParams = UnitTest.initializeValidationRun(varargin);
    
    % Initialize return params
    if (originalNargout > 0) returnItems = {'', false, [], [], []}; end
    
    if (originalNargout == 0)
        runTimeParams.printValidationReport = true;
        runTimeParams.generatePlots = true;
    end
    
    %% Call the validation function
    functionHandle(runTimeParams);

    %% Reporting and return params
    if (originalNargout > 0)
        [validationReport, validationFailedFlag, validationFundametalFailureFlag] = ...
                          UnitTest.validationRecord('command', 'return');
        validationData  = UnitTest.validationData('command', 'return');
        extraData       = UnitTest.extraData('command', 'return');
        returnItems     = {validationReport, validationFailedFlag, validationFundametalFailureFlag, validationData, extraData};
    else
        if (runTimeParams.printValidationReport)
            [validationReport, ~] = UnitTest.validationRecord('command', 'return');
            UnitTest.printValidationReport(validationReport);
        end 
        returnItems = {};
    end
end
