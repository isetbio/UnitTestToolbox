% Parse data "coordinates" like artifactId from a local file path.
function [remotePath, artifactId] = RemoteDataCoordinatesForFilePath(dataFileName)
    
    % parse remote data "coordinates" from the file path
    [dataFilePath, dataFileBase] = fileparts(dataFileName);
    [~, dataFileSubfolder] = fileparts(dataFilePath);
    nameParts = strsplit(dataFileBase, '_');
    artifactId = nameParts{2};
    
    if numel(nameParts) >=3 && strcmp(nameParts{3}, 'FastGroundTruthDataHistory')
        dataFlavor = 'fast';
    else
        dataFlavor = 'full';
    end
    
    remotePath = rdtFullPath({'', 'validation', dataFlavor, dataFileSubfolder});
end
