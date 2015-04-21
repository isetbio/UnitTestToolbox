% Method to generate the directory path/subDir, if this directory does not exist
function directoryExistedAlready = generateDirectory(obj, path, subDir)
    fullDir = sprintf('%s/%s', path, subDir);
    directoryExistedAlready = true;
    if (~exist(fullDir, 'dir'))
        directoryExistedAlready = false;
        mkdir(fullDir);
    end
end