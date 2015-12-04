% Method to export a validation entry to a validation file
% remotePath, artifactId, fastVsFull, data, version
function exportData(obj, dataFileName, validationData, extraData)
    runData.validationData        = validationData;
    runData.extraData             = extraData;
    runData.validationTime        = datestr(now);
    runData.hostInfo              = obj.hostInfo;
    
    % Choose export strategy and delegate to subfunction.
    if (obj.useRemoteDataToolbox)
        toRemoteDataToolbox(obj, dataFileName, runData);
    else
        toLocalFile(obj, dataFileName, runData);
    end
    
end

% Export data using Remote Data Toolbox.
function toRemoteDataToolbox(obj, dataFileName, runData)
    
    % parse remote data "coordinates" from the file path
    [remotePath, artifactId] = RemoteDataCoordinatesForFilePath(dataFileName);
    
    % does a version of this artifact exist yet?
    client = RdtClient(obj.remoteDataToolboxConfig);
    client.crp(remotePath);
    try
        % try to fetch latest version
        [~, artifact] = client.readArtifact(artifactId, 'type', 'mat');
        versionNumber = sscanf(artifact.version, 'run%d');
        if isempty(versionNumber)
            versionNumber = 1;
        end
    catch e
        versionNumber = 1;
    end
    version = sprintf('run%05d', versionNumber);
    
    % write a temp file and publish it
    tempFolder = fullfile(tempdir(), 'exportData');
    if 7 ~= exist(tempFolder, 'dir')
        mkdir(tempFolder);
    end
    tempFile = fullfile(tempFolder(), [artifactId '.mat']);
    save(tempFile, '-struct', 'runData');
    client.publishArtifact(tempFile, ...
        'artifactId', artifactId, ...
        'version', version);
    delete(tempFile);
end

% Export data to a local file.
function toLocalFile(obj, dataFileName, runData)
    
    if (obj.useMatfile)
        % create a MAT-file object for write access
        matOBJ = matfile(dataFileName, 'Writable', true);
        
        % get current variables
        varList = who(matOBJ);
        
        % add new variable with new validation data
        validationDataParamName = sprintf('run%05d', length(varList)+1);
        eval(sprintf('matOBJ.%s = runData;', validationDataParamName));
    else
        if (exist(dataFileName, 'file'))
            varList = who('-file', dataFileName);
        else
            varList = [];
        end
        validationDataParamName = sprintf('run%05d', length(varList)+1);
        eval(sprintf('%s = runData;', validationDataParamName));
        if (length(varList) == 0)
            eval(sprintf('save(''%s'', ''%s'');',dataFileName, validationDataParamName));
        else
            eval(sprintf('save(''%s'', ''%s'', ''-append'');',dataFileName, validationDataParamName));
        end
    end
    
    if (obj.validationParams.verbosity > 3)
        if (length(varList)+1 == 1)
            fprintf('\tFull validation file : now contains %d instance of historical data.\n', length(varList)+1);
        else
            fprintf('\tFull validation file : now contains %d instances of historical data.\n', length(varList)+1);
        end
    end
end