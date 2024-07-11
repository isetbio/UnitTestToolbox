function [status, report] = runProjectTutorials(p, scriptsToSkip, scriptCollection)
% Method to run the scripts in the tutorialsSourceDir
%
% Syntax:
%  [status, report] = runProjectTutorials(p, scriptsToSkip, scriptCollection)
%
% Outputs:
%   status    - Returns true if all ran OK, false otherwise.
%   report    - Print out of what happened for each script
%
% The params struct (p) has these variables:
%  - rootDirectory
%  - ghPagesCloneDir
%  - wikiCloneDir
%  - tutorialsSourceDir
%  - tutorialsTargetHTMLsubdir
%  - tutorialDocsURL
%  - verbosity
%  - headerText
%
% We use this method to run the validations scripts by pointing the
% tutorialsSourceDir at the validation directory in the calling
% routine.
%
% See also
%

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
    % Should we skip this one because it is listed as should be skipped?
    % Things to skip are strings that appear anywhere in the file's full
    % pathname.
    skipThisOne = false;
    for l = 1:numel(scriptsToSkip)
        s = scriptsToSkip{l};
        skipTest = strfind(filesList{ii}, s);
        if (~isempty(skipTest))
            skipThisOne = true;
        end
    end
    if (skipThisOne)
        tutorialOK(ii) = -1;
        continue;
    end

    % Another reason to skip is if the tutorial itself has a comment
    % line that says UTTBSkip.  To determine this we need to read the
    % source and scan for that line.
    % Open file
    theFileH = fopen(filesList{ii},'r');
    theFileText = char(fread(theFileH,'uint8=>char')');
    fclose(theFileH);
    skipTest = strfind(theFileText,'% UTTBSkip');
    clear theFileText
    if (~isempty(skipTest)) %#ok<*STREMP>
        fprintf('\tFile %s contains ''%% UTTBSkip'' - skipping.\n',filesList{ii});
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

    % Force a draw to make sure we clear some memory and process
    drawnow;
    close all;
    drawnow;
    
    cd(curdir);
end

%% Report of what happened
%
% Could use addText for ISET, but maybe not for other repositories.
fprintf('\n ***** Summary tests *****\n');
report = sprintf('\n ***** Summary tests *****\n');
for ii = 1:length(filesList)
    fprintf('%s -- ',filesList{ii});
    report = [report, sprintf('%s -- ',filesList{ii})]; %#ok<*AGROW>
    if (tutorialOK(ii) == 1)
        fprintf(' OK!\n');
        report = [report, sprintf(' OK!\n')];
    elseif (tutorialOK(ii) == -1)
        fprintf(' SKIPPED\n');
        report = [report, sprintf(' SKIPPED\n')];
    else
        fprintf(2,' ******** BROKEN! ***********\n');
        report = [report, sprintf(' ******** BROKEN! ***********\n')];
    end
end

%disp(report);

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

