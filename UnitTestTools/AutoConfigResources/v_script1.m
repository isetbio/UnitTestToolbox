
function varargout = v_script1(varargin)
%
% Description of what the script does
%

    varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the validation code
function ValidationFunction(runTimeParams)

    % Code goes here

    % Add some useful message
    UnitTest.validationRecord('SIMPLE_MESSAGE', 'Test 1. Copy and adapt to your needs.');
    
    % Add validation data
    var1 = ones(1,10);
    UnitTest.validationData('data1ToCompare',var1);
    
    % Internal test for some data to be equal within some tolerance
    quantityOfInterest = randn(100,1)*0.0000001;
    tolerance = 0.000001;
    UnitTest.assertIsZero(quantityOfInterest,'Result',tolerance);
    
    %% Simple assertion
    fundamentalCheckPassed = true;
    UnitTest.assert(fundamentalCheckPassed,'fundamental assertion');
    
    % add additional data. these will not be tested against ground truth
    additionalData = rand(1,10);
    UnitTest.extraData('someAdditionalData', additionalData);
    
    %% Plotting goes here
    if (runTimeParams.generatePlots)
        figure(1);
        plot(quantityOfInterest, quantityOfInterest.^2, 'ks');
    end
    
end


