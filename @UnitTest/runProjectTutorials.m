function status = runProjectTutorials(p, scriptsToSkip, scriptCollection)
% Method to run a project's tutorials
%
% Syntax:
%    status = runProjectTutorials(p, scriptsToSkip, scriptCollection)
%
% Outputs:
%    status    - Returns true if all ran OK, false otherwise.
% 
    % Unload params struct
    % These are:
    % - rootDirectory
    % - ghPagesCloneDir
    % - wikiCloneDir
    % - tutorialsSourceDir
    % - tutorialsTargetHTMLsubdir
    % - tutorialDocsURL
    % - verbosity
    % - headerText
    varNames = fieldnames(p);
    for k = 1:numel(varNames)
        eval(sprintf('%s = p.%s;', varNames{k}, varNames{k}));
    end
    
    %% Get the list of tutorials to run
    filesFullList = getContents(tutorialsSourceDir, {});
    if strcmp(scriptCollection, 'All')
        filesList = filesFullList;
    else
        filesList = selectSingleTutorial(filesFullList, scriptsToSkip, tutorialsSourceDir);
    end
    
    %% Run the tutorials, catching errors.
    curdir = pwd;
    tutorialOK = zeros(length(filesList),1);
    for ii = 1:length(filesList)
        % Should we skip this one?
        skipThisOne = false;
        for l = 1:numel(scriptsToSkip)
            s = scriptsToSkip{l};
            if (strfind(filesList{ii}, s))
                skipThisOne = true;
            end
        end
        if (skipThisOne)
            tutorialOK(ii) = -1;
            continue;
        end
        
        % Not skipping, run and catch error if broken
        [tutorialDirectoryName,tutorialName] = fileparts(filesList{ii});
        cd(tutorialDirectoryName)
        try
            fprintf('Running %s\n',filesList{ii});
            runTheTutorial(tutorialName);
            tutorialOK(ii) = true;
        catch
            tutorialOK(ii) = false;
        end
        cd(curdir);
    end
    
    %% Report of what happened
    fprintf('\n ***** Summary of tutorials run *****\n');
    for ii = 1:length(filesList) 
        fprintf('%s -- ',filesList{ii});
        if (tutorialOK(ii) == 1)
            fprintf('OK!\n'); 
        elseif (tutorialOK(ii) == -1)
            fprintf('SKIPPED\n');
        else
            fprintf(2,'BROKEN!\n');   
        end
    end
    
    %% Return status
    status = all(tutorialOK);
    
end


function updatedFileList = getContents(directory, fileList)
    oldFileList = fileList;
    cd(directory);
    
    % look for m-files
    contents = dir('*.m');
    for k = 1:numel(contents)
        oldFileList{numel(oldFileList)+1} = fullfile(directory,contents(k).name);
    end
    
    % look for subdirs
    contents = dir;
    for k = 1:numel(contents)
        if (contents(k).isdir) && (~strcmp(contents(k).name, '.')) && (~strcmp(contents(k).name, '..')) && (~strcmp(contents(k).name, 'html'))
           oldFileList = getContents(fullfile(directory,contents(k).name), oldFileList); 
        end
    end
    
    updatedFileList = oldFileList;
end

%% Run the tutorial in a clean workspace
function runTheTutorial(theTutorial)

eval(theTutorial);

end

