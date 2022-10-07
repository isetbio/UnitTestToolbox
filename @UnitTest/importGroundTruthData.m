% Method to import a ground truth data entry
function [validationData, extraData, validationTime, hostInfo] = importGroundTruthData(obj, dataFileName)
    % Choose loading strategy and delegate to subfunction.
    if (obj.useRemoteDataToolbox)
        [validationData, extraData, validationTime, hostInfo] = fromRemoteDataToolbox(obj, dataFileName);
    else
        [validationData, extraData, validationTime, hostInfo] = fromLocalFile(obj, dataFileName);
    end
end

% Load remote data with Remote Data Toolbox.
function [validationData, extraData, validationTime, hostInfo] = fromRemoteDataToolbox(obj, dataFileName)
    
    % parse remote data "coordinates" from the file path
    [remotePath, artifactId] = RemoteDataCoordinatesForFilePath(dataFileName);
        
    % fetch the artifact data (defaults to latest version)
    client = RdtClient(obj.remoteDataToolboxConfig);
    client.crp(remotePath);
    
    try
        [runData, artifact] = client.readArtifact(artifactId, 'type', 'mat');
        
        if (obj.validationParams.verbosity > 3)
            fprintf('\tGround truth  url    : %s\n', artifact.url);
            fprintf('\tGround truth  localP : %s\n', artifact.localPath);
        end
        
        hostInfo        = runData.hostInfo;
        validationTime  = runData.validationTime;
        validationData  = runData.validationData;
        extraData       = runData.extraData;
    catch e
        hostInfo        = [];
        validationTime  = [];
        validationData  = [];
        extraData       = [];
    end
end

% Load data from a local file.
function [validationData, extraData, validationTime, hostInfo] = fromLocalFile(obj, dataFileName)
    if (2 ~= exist(dataFileName, 'file'))
        hostInfo        = [];
        validationTime  = [];
        validationData  = [];
        extraData       = [];
        return;
    end
    
    if (obj.validationParams.verbosity > 3)
        fprintf('\tGround truth  file   : %s\n', dataFileName);
    end
    
    if (obj.useMatfile)
        % create a MAT-file object for read access
        matOBJ = matfile(dataFileName);
        
        % get current variables
        varList = who(matOBJ);
    else
        varList = who('-file', dataFileName);
    end
    
    if (obj.validationParams.verbosity > 3)
        if (length(varList) == 1)
            fprintf('\tFull validation file : contains %d instance of historical data.\n', length(varList));
        else
            fprintf('\tFull validation file : contains %d instances of historical data. Retrieving latest one.\n', length(varList));
        end
    end
    
    % get latest validation data entry
    validationDataParamName = sprintf('run%05d', length(varList));
    
    if (obj.useMatfile)
        eval(sprintf('runData = matOBJ.%s;', validationDataParamName));
    else
        % Changed by NPC on Oct 7, 2022 to enable running locally
        %eval(sprintf('load(''%s'', ''%s'');',dataFileName, validationDataParamName));
        %eval(sprintf('runData = %s;', validationDataParamName));
        eval(sprintf('runData = load(''%s'');',dataFileName));
    end
    % return the validationData and time
    hostInfo        = runData.hostInfo;
    validationTime  = runData.validationTime;
    validationData  = runData.validationData;
    extraData       = runData.extraData;
end