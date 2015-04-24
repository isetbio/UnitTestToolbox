% Method to publish a project's tutorials
function publishProjectTutorials(p, scriptsToSkip, scriptCollection)

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
    
    
    filesFullList = getContents(tutorialsSourceDir, {});
    
    
    if strcmp(scriptCollection, 'All')
        filesList = filesFullList;
    else
        filesList = selectSingleTutorial(filesFullList, scriptsToSkip, tutorialsSourceDir);
    end
    
    sectionData = parseTutorialsDirSections(filesList, scriptsToSkip, tutorialsSourceDir);
    
    
    % Directory where all published HTML directories will be moved to
    tutorialDocsDir  = sprintf('%s/tutorialdocs', ghPagesCloneDir);
    tutorialsHTMLdir = tutorialDocsDir;
    
    
    % set to true when having trouble synchronizing with github  
    removeAllTargetHTMLDirs = false;
    
    
    if (numel(filesList) > 1)
        system(sprintf('rm -r -f %s/*',tutorialDocsDir));
        if (verbosity > 1)
           fprintf('Removing previously existing dir ''%s''\n', tutorialDocsDir);
        end
    end
    
  
    % generate tutorialsHTMLdir
    if (exist(tutorialDocsDir, 'dir')==7)
        if (removeAllTargetHTMLDirs)
            if (verbosity > 1)
                fprintf('Removing previously existing dir ''%s''\n', tutorialDocsDir);
            end
            system(sprintf('rm -r -f %s/*',tutorialDocsDir));
        else
            % cd to tutorialDocsDir and update it
            cd(tutorialDocsDir);
    
            % Do a git pull (so we can push later with no conflicts)
            issueGitCommand('git pull', verbosity);
        end
    else    
        mkdir(tutorialDocsDir);
    end

    
    
    % cd to wikiCloneDir and update it
    cd(wikiCloneDir);
    issueGitCommand('git pull', verbosity);

    % Name of the markup file containing the catalog of validation runs and
    % pointers to the corresponding html files.
    catalogFileName = fullfile(wikiCloneDir, 'Tutorials.md');
    

    
    if (numel(filesList) > 1)
        % Now we start modifying things
        % Remove previous validationResultsCatalogFile
        system(['rm -rf ' catalogFileName]);
        
        % Open new catalog file
        tutorialsCatalogFileFID = fopen(catalogFileName,'w');
    
        % Write the header text.
        fprintf(tutorialsCatalogFileFID, headerText);
        fprintf(tutorialsCatalogFileFID,'***\n_**Last run performed on %s**._\n***', datestr(now));
    else
        % Open the file in read/write mode, so we can update the date for
        % the single script.
        tutorialsCatalogFileFID = fopen(catalogFileName,'r+');
    end
    
    k = 0;
    
    sectionNames = keys(sectionData);
    for sectionIndex = 1:numel(sectionNames)
        
        isSingleFileWithNewSection = false;
        % write sectionName
        sectionName = sectionNames{sectionIndex};
        if (numel(filesList) > 1)
            fprintf(tutorialsCatalogFileFID,'\n####  %s \n', sectionName);
        else
           % search the file for the pattern
           patternToLookUp = sprintf('####  %s', sectionName);
           fseek(tutorialsCatalogFileFID, 0, 'bof');
           position = [];
           while ~feof(tutorialsCatalogFileFID) 
                tline = fgetl(tutorialsCatalogFileFID); 
                if strfind(tline, patternToLookUp) > 0 
                    %fprintf('%s :: Found pattern ''%s''\n.', tline, patternToLookUp);
                    position = ftell(tutorialsCatalogFileFID);
                end
           end
           if (~isempty(position))
               % Go right before the sectionName
               fseek(tutorialsCatalogFileFID, position, 'bof');
           else
               % Go to the end of the file
               fseek(tutorialsCatalogFileFID, 0, 'eof');
               % and write new section name
               fprintf(tutorialsCatalogFileFID,'\n####  %s \n', sectionName);
               isSingleFileWithNewSection = true;
           end
        end
        
        % Write section info text
        functionNames = sectionData(sectionName);
        if (isempty(functionNames))
            if (numel(filesList) > 1) || (isSingleFileWithNewSection)
                fprintf(tutorialsCatalogFileFID,'_This section contains no tutorials._ \n');
            end
            continue;
        end
        
        [tutorialScriptDirectory, ~, ~] = fileparts(char(functionNames{1}));
        
        cd(tutorialScriptDirectory);
        if (numel(filesList) > 1) || (isSingleFileWithNewSection)
            infoFileName = sprintf('%s/info.txt', tutorialScriptDirectory);
            if (exist(infoFileName, 'file'))
                fprintf(tutorialsCatalogFileFID,'_%s_ \n', sprintf('%s', fileread(infoFileName)));
            else
                fprintf(tutorialsCatalogFileFID,'_There is no information file (info.txt) for section ''%s''_ \n', sectionName);
            end
        end
        
        
        for functionIndex = 1:numel(functionNames)
            tutorialScriptName = sprintf('%s', char(functionNames{functionIndex}));
            
            if (~ismember(tutorialScriptName, filesList))
               continue; 
            end
            
            % Determine script small name and sub-directory
            indices = strfind(tutorialScriptName, filesep);
            smallScriptName = tutorialScriptName(indices(end)+1:end-2);

            [tutorialScriptDirectory, ~, ~] = fileparts(tutorialScriptName);
            seps = strfind(tutorialScriptName, '/');
            tutorialScriptSubDir = tutorialScriptDirectory(seps(end-1)+1:end);
            
            % make subdir in local validationDocsDir 
            sectionWebDir = fullfile(tutorialDocsDir , tutorialScriptSubDir);
            if (~exist(sectionWebDir,'dir'))
                mkdir(sectionWebDir);
            end
            
          
            % cd to validationRootDirectory/sectionSubDir
            cd(sprintf('%s', tutorialScriptDirectory));
            
            k = k + 1;
            
            if (numel(filesList) > 1)
                fprintf('[%2d]. Running and publishing script ''%s'' in directory ''%s''\n', k, smallScriptName, tutorialScriptDirectory);
            else
                fprintf('Running and publishing script ''%s'' in directory ''%s''\n', smallScriptName, tutorialScriptDirectory);
            end
        
            runtimeError = false;
            try
                options.catchError = false;
                HTMLfile = publish(smallScriptName, options);
                idx = strfind(HTMLfile, '/html/');
                sourceHTMLdir = HTMLfile(1:idx+length('/html/')-2);
                sectionAndScript = tutorialScriptName(length(tutorialsSourceDir)+1:end-2);
                targetHTMLdir = fullfile(tutorialsHTMLdir, sectionAndScript);
            catch err
                fprintf(2, '\tScript ''%s'' raised a runtime error (''%s'')\n', smallScriptName, err.message);
                runtimeError = true;
            end
        
            if (runtimeError)
                continue;
            end
        
            
            
            if (exist(sourceHTMLdir, 'dir') == 0)
                fprintf(2,'\n>>>> Directory %s not found.\n', sourceHTMLdir);
                return;
            end
            
            if (removeAllTargetHTMLDirs)
                % remove any existing target HTML directory
                system(sprintf('rm -rf %s', targetHTMLdir));
            end
            
            if (exist(targetHTMLdir, 'dir') == 0)
                fprintf('Generating target HTML dir (''%s'')\n', targetHTMLdir);
                system(sprintf('mkdir %s', targetHTMLdir));
            end
            
            
            
            tutorialURL = sprintf('%s/%s/%s/%s.html', tutorialDocsURL, sectionName, smallScriptName, smallScriptName);
            

            % mv source to target directory
            system(sprintf('mv %s/* %s/',  sourceHTMLdir, targetHTMLdir));

            % delete sourceHTMLdir
            system(sprintf('rm -r -f %s', sourceHTMLdir));
            
            % get summary text from validation script.
            summaryText = getSummaryText(smallScriptName);
            
            if (numel(filesList) > 1) || (isSingleFileWithNewSection)
               % Add entry to tutorialsCatalogFile
                fprintf(tutorialsCatalogFileFID, '* [ %s ](%s) - %s\n',  smallScriptName, tutorialURL, summaryText);  
            else
                patternToLookUp = sprintf('* [ %s ]', smallScriptName);
                fseek(tutorialsCatalogFileFID, 0, 'bof');
                fileContents = fscanf(tutorialsCatalogFileFID, '%c', Inf);
                position = strfind(fileContents, patternToLookUp)-1;
                
                if (~isempty(position))
                    userName =  char(java.lang.System.getProperty('user.name'));
                    computerAddress  = char(java.net.InetAddress.getLocalHost.getHostName);
                    insertedFileContents = sprintf('\n***Note: Script ''%s'' was updated separately on %s by %s (host name: %s).***\n', smallScriptName, datestr(now), userName, computerAddress);
                    newFileContents(1:position) = fileContents(1:position);
                    remainingFileContents = fileContents(position+1:end);
                    newFileContents(position+1:position+numel(insertedFileContents)) = insertedFileContents;
                    p = numel(newFileContents);
                    newFileContents(p+1:p+numel(remainingFileContents)) = remainingFileContents;
                    fclose(tutorialsCatalogFileFID);
                    
                    system(['rm -rf ' catalogFileName]);
    
                    % Open new validationResultsCatalogFile
                    tutorialsCatalogFileFID = fopen(catalogFileName,'w');
                    fprintf(tutorialsCatalogFileFID, '%c', newFileContents);
                else
                    % Go to the end of the file
                    fseek(tutorialsCatalogFileFID, 0, 'eof');
                    % And add entry to validationResultsCatalogFile
                    fprintf(tutorialsCatalogFileFID, '* [ %s ](%s) - %s \n',  smallScriptName, tutorialURL, summaryText);  
                end
                
            end
            
        end % functionIndex 
    end % sectionIndex
    
    
  


    % Close the tutorialsCatalogFileFID
    fclose(tutorialsCatalogFileFID);
    
    cd(tutorialsHTMLdir);
    
    % -------- Push the HTML tutorial datafiles ---------
    cd(tutorialsHTMLdir);
    
    issueGitCommand('git config --global push.default matching', verbosity);

    % Stage everything
    issueGitCommand('git add -A', verbosity);
    
    % Commit everything
    if (numel(filesList) > 1)
        issueGitCommand('git commit -a -m "Tutorials docs update";', verbosity);
    else
        issueGitCommand('git commit -a -m "Single tutorial doc update";', verbosity);
    end
    % Push to remote
    issueGitCommand('git push  origin gh-pages',verbosity);
    
    
    
    
    % ---------- Push the tutorials catalog -------------
    cd(wikiCloneDir);
    
    issueGitCommand('git config --global push.default matching', verbosity);
    
    % Stage everything
    issueGitCommand('git add -A', verbosity);
    

    % Commit everything
    issueGitCommand('git commit  -a -m "Tutorials catalog update";', verbosity);
    % Push to remote
    issueGitCommand('git push', verbosity);
    
    % All done. Return to root directory
    cd(rootDirectory);
end

function tutorialToPublish = selectSingleTutorial(filesFullList, scriptsToSkip, tutorialsSourceDir)
    
    fprintf('\n\n---------------------------------------------------------------------------\n');
    fprintf('Available tutorials                                     Tutorial no. \n');
    fprintf('---------------------------------------------------------------------------\n');
                
    existingSectionNames = {};
    filesList = {};
    for k = 1:numel(filesFullList)
        scriptName = filesFullList{k};
        skipThisOne = false;
        for l = 1:numel(scriptsToSkip)
            s = scriptsToSkip{l};
            if (strfind(scriptName, s))
                skipThisOne = true;
            end
        end
        
        if (skipThisOne)
            continue;
        end
        
        filesList{numel(filesList)+1} = scriptName;
        
        sectionAndScript = scriptName(length(tutorialsSourceDir)+1:end-2);
        idx = strfind(sectionAndScript, '/');
        sectionName     = sectionAndScript(2:idx(2)-1);
        smallScriptName = sectionAndScript(idx(2)+1:end);
        
        if (~ismember(sectionName, existingSectionNames))
           existingSectionNames{numel(existingSectionNames)+1} = sectionName;
           fprintf('<strong>%s</strong>\n', sectionName);
        end
        dots = '';
        for kk = 1:50-numel(smallScriptName)
           dots(kk) = '.';
        end
        fprintf('\t%s %s %3d\n',  smallScriptName, dots, numel(filesList));
    end % for k
    
    selectedScriptIndex = input(sprintf('\nEnter tutorial no. to publish [%d-%d]: ', 1, numel(filesList)));
    if (isempty(selectedScriptIndex)) || (~isnumeric(selectedScriptIndex))
        error('input must be a numeral');
    elseif (selectedScriptIndex <= 0) || (selectedScriptIndex > numel(filesList))
        error('input must be in range [%d .. %d]', 1, numel(filesList));
    else
        tutorialToPublish = {filesList{selectedScriptIndex}};
    end
    
end

function sectionData = parseTutorialsDirSections(filesFullList, scriptsToSkip, tutorialsSourceDir)

    sectionData  = containers.Map();
    
    for k = 1:numel(filesFullList) 
        scriptName = filesFullList{k};
        skipThisOne = false;
        for l = 1:numel(scriptsToSkip)
            s = scriptsToSkip{l};
            if (strfind(scriptName, s))
                skipThisOne = true;
            end
        end
        
        if (skipThisOne)
            continue;
        end
        
        sectionAndScript = scriptName(length(tutorialsSourceDir)+1:end-2);
        idx = strfind(sectionAndScript, '/');
        theSectionName     = sectionAndScript(2:idx(2)-1);
        theSmallScriptName = sectionAndScript(idx(2)+1:end);
        s = {};
        if (isKey(sectionData,theSectionName))
            s = sectionData(theSectionName);
            s{numel(s)+1} = scriptName;
        else
            s{1} = scriptName; 
        end
        sectionData(theSectionName) = s;
    end

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


% Method to issue a git command with output capture
function issueGitCommand(commandString, verbosity)

    [status,cmdout] = system(commandString,'-echo');
    
    if (verbosity > 1)
        disp(cmdout)
    end
end

function summaryText = getSummaryText(validationScriptName)
    % Open file
    fid = fopen(which(validationScriptName),'r');

    % Throw away first two lines
    lineString = fgetl(fid);
    lineString = fgetl(fid);

    % Get line with function description (3rd lone)
    lineString = fgetl(fid);
    % Remove any comment characters (%)
    summaryText  = regexprep(lineString ,'[%]','');
    
    fclose(fid);
end
