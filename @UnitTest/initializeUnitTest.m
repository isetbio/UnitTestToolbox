% Method to initialize the instantiated @UnitTest object
function initializeUnitTest(obj)
    % setup default validation params
    for k = 1:numel(UnitTest.validationOptionNames)
        eval(sprintf('obj.defaultValidationParams.%s = UnitTest.validationOptionDefaultValues{k};', UnitTest.validationOptionNames{k}));
    end

    % setup default directories
    % get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    obj.rootDir    = getpref(theProjectName, 'validationRootDir');
    obj.htmlDir    = fullfile(obj.rootDir, 'HTMLpublishedData', filesep);
    
    % initialize validation params to default params
    obj.validationParams = obj.defaultValidationParams;
    
    % initialize verbosity based on current project prefs
    verbosity = getpref(theProjectName, 'verbosity');
    if (ismember(verbosity, UnitTest.validVerbosityLevels))
       obj.validationParams.verbosity = find(strcmp(verbosity,UnitTest.validVerbosityLevels)==1)-2;
    else
       error('Verbosity level ''%s'', not recognized', verbosity); 
    end
        
    % initialize numeric tolerance based on current project prefs
    obj.validationParams.numericTolerance = getpref(theProjectName, 'numericTolerance');
    
    % initialize mismatch data graphing
    obj.validationParams.graphMismatchedData = getpref(theProjectName, 'graphMismatchedData');
    
    % initialize compareStringFields
    obj.validationParams.compareStringFields = getpref(theProjectName, 'compareStringFields');
    
    obj.dataMismatchFigNumber = UnitTest.minFigureNoForMistmatchedData;
    
    % initialize section map (for github wiki)
    obj.sectionData  = containers.Map();
    
    % get info about host computer
    obj.hostInfo = struct();
    obj.hostInfo.matlabVersion    = version;
    obj.hostInfo.computer         = computer;
    obj.hostInfo.computerAddress  = char(java.net.InetAddress.getLocalHost.getHostName);
    obj.hostInfo.userName         = char(java.lang.System.getProperty('user.name'));
end
