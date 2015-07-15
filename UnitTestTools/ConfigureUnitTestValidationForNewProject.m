function ConfigureUnitTestValidationForNewProject

    % save current directory so we can return to it
    currentDir = pwd;
    
    % Get the auto config resource dir
    AutoConfigResourceDir = GetAutoConfigResourceDir();
    
    projectName = input('\n<strong> STEP 1/6  </strong> Enter UnitTest project name (e.g., BLIllumCalcs) : ', 's');
    if (isempty(projectName))
        fprintf(2,'Invalid project name\n');
        return;
    end
    
    % Get the directory where the wiki repository is cloned
    d = input('\n<strong> STEP 2/6  </strong> Have you cloned the github wiki repository on your local computer ? [y/n] : ', 's');
    if (strcmp(d, 'y'))
        fprintf('\t    Select the directory where the github <strong>wiki</strong>  repository is cloned.\n');
        clonedWikiLocation = uigetdir('/Users/Shared/Matlab', sprintf('Select the directory where the github wikirepository is cloned.'));
    else
        fprintf(2,'Please clone the github wiki repository and re-run this script.\n');
        return;
    end
    if (isempty(clonedWikiLocation))
        fprintf(2,'Invalid github wiki repository location\n');
        return;
    end
    
    % Get the directory where the gh-pages repository is cloned
    d = input('\n<strong> STEP 3/6  </strong> Have you cloned the github gh-pages repository on your local computer ? [y/n] : ', 's');
    if (strcmp(d, 'y'))
        fprintf('\t    Select the directory where the github <strong>gh-pages</strong>  repository is cloned.\n');
        clonedGhPagesLocation = uigetdir('/Users/Shared/Matlab', sprintf('Select the directory where the github gh-pagesrepository is cloned.'));
    else
        fprintf(2,'Please clone the github gh-pages repository and re-run this script.\n');
        return;
    end
    if (isempty(clonedGhPagesLocation))
        fprintf(2,'Invalid github gh-pages repository location\n');
        return;
    end
    

    % Create or select the validation root dir
    fprintf('\n<strong> STEP 4/6  </strong> Select the location where to create the <strong>validation</strong> and <strong>tutorials</strong> root directories \n');
    subfolderDir = uigetdir('/Users/Shared/Matlab', sprintf('Select where to create the validation and tutorials root directories for project ''%s'' .', projectName));
    if isempty(subfolderDir)
        fprintf(2,'Invalid validation root directory\n');
        return;
    else
        validationRootSuperDir = subfolderDir;
        fprintf('            Validation and tutorials root directories will be created under  ''%s'' \n',validationRootSuperDir);
    end
    
   
    
    % Finally get the URLs
    fprintf('\n<strong> STEP 5/6  </strong> URL of the github repository, e.g., ''https://github.com/isetbio/BLIlluminationDiscriminationCalcs.git''\n');
    githubRepoURL    = input('            URL : ', 's');
    fprintf('\n<strong> STEP 6/6  </strong> URL of the github repository, e.g., ''http://isetbio.github.io/BLIlluminationDiscriminationCalcs/tutorialdocs''\n');
    tutorialsDocsURL = input('            URL : ', 's');
    fprintf('\n\n');
    
    % ---------------------- VALIDATION  ------------------------------
    
    cd(validationRootSuperDir);
    if (~exist(fullfile(validationRootSuperDir, 'validation'), 'dir'))
        mkdir('validation');
    end
    cd('validation');
    validationRootDir = pwd
    
    % Check the scripts directory exists and generate it if it does not exist
    cd(validationRootDir);
    if (~exist(fullfile(validationRootDir, 'scripts'), 'dir'))
        mkdir('scripts');
    end
    
    
    % Generate a couple of demo script directories
    cd('scripts');
    scriptsDir = pwd;
    validationScriptDirs= {'category1scripts', 'category2scripts'};
    for k = 1:numel(validationScriptDirs)
        mkdir(char(validationScriptDirs{k}));
        cd(char(validationScriptDirs{k}));
        system(sprintf('cp %s/v_script1.m .', AutoConfigResourceDir));
        system(sprintf('cp %s/v_info%d.txt ./info.txt', AutoConfigResourceDir,k));
        cd(scriptsDir);
    end
    
    % Generate validationListAllValidationDirs
    cd(validationRootDir);
    validationListAllValidationDirsScriptName = sprintf('validateListAllValidationDirsForProject%s', projectName);
    system(sprintf('cp %s/validateListAllValidationDirs.m ./%s.m', AutoConfigResourceDir, validationListAllValidationDirsScriptName));
    
    
    % Generate UnitTest preferences file   
    UnitTestPreferencesFileName = GenerateUnitTestPreferencesFile(projectName, validationRootDir, validationListAllValidationDirsScriptName, clonedWikiLocation, clonedGhPagesLocation, githubRepoURL);
    run(sprintf('%s', UnitTestPreferencesFileName));
    
    % Generate the various validate_xxx scripts
    validationScripts = {...
        'validateFastAll.m' ...
        'validateFullAll.m' ...
        'validateFullOne.m' ...
        'validateFullAndPublishAll.m' ...
        };
    for k = 1:numel(validationScripts)
        GenerateValidationScript(char(validationScripts{k}), projectName, AutoConfigResourceDir, validationRootDir);
    end
    % ------------------------ TUTORIALS -------------------------
    
    
    % Check whether the tutorials directory exists and generate it if it does not exist
    cd(validationRootSuperDir);
    if (~exist(fullfile(validationRootSuperDir, 'tutorials'), 'dir'))
        mkdir('tutorials');
    end
    
    % Generate a couple of demo tutorials directories
    cd('tutorials');
    tutorialsDir = pwd;
    tutorialsScriptDirs = {'category1tutorials', 'category2tutorials'};
    for k = 1:numel(tutorialsScriptDirs)
        mkdir(char(tutorialsScriptDirs{k}));
        cd(char(tutorialsScriptDirs{k}));
        system(sprintf('cp %s/t_script1.m .', AutoConfigResourceDir));
        system(sprintf('cp %s/t_info%d.txt ./info.txt', AutoConfigResourceDir,k));
        cd(tutorialsDir);
    end
    
    
    % Generate the publishAllTutorials file
    GeneratePublishAllTutorialFile(projectName, validationRootDir, tutorialsDir, tutorialsDocsURL);
    
    cd(currentDir);
end


function GenerateValidationScript(validationScript, projectName, autoConfigResourceDir, validationRootDir)

    fid  = fopen(fullfile(autoConfigResourceDir, validationScript),'r');
    fileContents = fread(fid,'*char')';
    fclose(fid);

    fileContents = strrep(fileContents,'xxyyzzprojectname', projectName);
    
    fid  = fopen(fullfile(validationRootDir, validationScript),'w');
    fprintf(fid,'%s',fileContents);
    fclose(fid);

end


function GeneratePublishAllTutorialFile(projectName, validationRootDir, tutorialsDir, tutorialsDocsURL)
    sections{1} = { ...
        sprintf('function publishAllTutorials') ...
        ' ' ...
        sprintf('    %% ------- script customization - adapt to your environment/project -----') ...
        ' ' ...
        sprintf('    %% user/project specific preferences') ...
        sprintf('    p = struct(...') ...
        sprintf('        ''rootDirectory'',            fileparts(which(mfilename())), ...                       %% the rootDirectory') ...
        sprintf('        ''ghPagesCloneDir'',          getpref(''%s'', ''clonedGhPagesLocation''), ... %% local directory where the project''s gh-pages branch is cloned', projectName) ...
        sprintf('        ''wikiCloneDir'',             getpref(''%s'', ''clonedWikiLocation''), ...    %% local directory where the project''s wiki is cloned', projectName) ...
        sprintf('        ''tutorialsSourceDir'',       ''%s'', ...                %% local directory where tutorial scripts are located', tutorialsDir) ...
        sprintf('        ''tutorialDocsURL'',          ''%s'', ...                %% URL where tutorial docs should go', tutorialsDocsURL) ...
        sprintf('        ''headerText'',               ''***\\n_This file is autogenerated by the publishAllTutorials script, located in the projects validation directory. Do not edit manually, as all changes will be overwritten during the next run._\\n***'', ...') ...
        sprintf('        ''verbosity'',                1 ...') ...
        sprintf('    );') ...
        ' ' ...
        };

    tutorialsAvailableAt = strrep(getpref(projectName,'githubRepoURL'), '.git', '/wiki/Tutorials');
    
    sections{2} = { ...
        sprintf('    %% list of scripts to be skipped from automatic publishing') ...
        sprintf('    scriptsToSkip = {...') ...
        sprintf('    };') ...
        ' ' ...
        sprintf('    %% ----------------------- end of script customization -----------------')...
        ' ' ...
        sprintf('    UnitTest.publishProjectTutorials(p, scriptsToSkip, ''All'');') ...
        sprintf('    fprintf(2,''Tutorials available at:  %s\\n'');', tutorialsAvailableAt) ...
        sprintf('end')...
        };

    PublishAllTutorialsFileName = fullfile(validationRootDir,'publishAllTutorials.m');
    
    fid = fopen(PublishAllTutorialsFileName, 'w');
    for l = 1:numel(sections)
        for k = 1:numel(sections{l})
            fprintf(fid, '%s\n',sections{l}{k});
        end
    end
    fclose(fid);

end

function UnitTestPreferencesFileName = GenerateUnitTestPreferencesFile(projectName, validationRootDir, validationListAllValidationDirsScriptName, clonedWikiLocation, clonedGhPagesLocation, githubRepoURL)

    sections{1} = sprintf('% Method to set %s-specific unit testing preferences.', projectName);
    
    sections{2} = { ...
        '%'
        '% Generally, this function should be edited for your site and then run once.'
        '%'
        ' '
        };
    
    sections{3} = { ...
        sprintf('function set%sUnitTestPreferences', projectName) ...
        ' '...
        '    % Specify project-specific preferences' ...
        '    p = struct(...' ...
        sprintf('            ''projectName'',                         ''%s'', ... \t %% The project name (also the preferences group name)', projectName) ...
        sprintf('            ''validationRootDir'',                   ''%s'', ... \t %% Directory location where the ''scripts'' subdirectory resides.', validationRootDir) ...
        sprintf('            ''alternateFastDataDir'',                '''',  ...  \t %% Alternate FAST (hash) data directory location. Specify '''' to use the default location, i.e., $validationRootDir/data/fast') ...
        sprintf('            ''alternateFullDataDir'',                '''',  ...  \t %% Alternate FAST (hash) data directory location. Specify '''' to use the default location, i.e., $validationRootDir/data/full') ...
        sprintf('            ''clonedWikiLocation'',                  ''%s'', ... \t %% Local path to the directory where the wiki is cloned. Only relevant for publishing tutorials.', clonedWikiLocation) ... 
        sprintf('            ''clonedGhPagesLocation'',               ''%s'', ... \t %% Local path to the directory where the gh-pages repository is cloned. Only relevant for publishing tutorials.', clonedGhPagesLocation) ... 
        sprintf('            ''githubRepoURL'',                       ''%s'', ... \t %% Github URL for the project. This is only used for publishing tutorials.', githubRepoURL) ... 
        sprintf('            ''generateGroundTruthDataIfNotFound'',   true, ...  \t %% Flag indicating whether to generate ground truth if one is not found') ...
        sprintf('            ''listingScript'',                       ''%s'' ...', validationListAllValidationDirsScriptName) ... 
        '      );' ...
        ' '...
        '    generatePreferenceGroup(p); ' ...
        '    UnitTest.usePreferencesForProject(p.projectName);' ...
        'end' ...
        ' '...
        };
    
    
    sections{4} = { ...
        'function generatePreferenceGroup(p)' ...
        '    % remove any existing preferences for this project' ...
        '    if ispref(p.projectName)' ...
        '        rmpref(p.projectName);' ...
        '    end' ...
        ' ' ...
        '    % generate and save the project-specific preferences' ...
        '    setpref(p.projectName, ''projectSpecificPreferences'', p);' ...
        '    fprintf(''Generated and saved preferences specific to the ''''%s'''' project.\n'', p.projectName);' ...
        'end'...
        };

    UnitTestPreferencesFileName = fullfile(validationRootDir,sprintf('set%sUnitTestPreferences.m', projectName));
    
    fid = fopen(UnitTestPreferencesFileName, 'w');
    for l = 1:numel(sections)
        for k = 1:numel(sections{l})
            fprintf(fid, '%s\n',sections{l}{k});
        end
    end
    fclose(fid);
    
end



function AutoConfigResourceDir = GetAutoConfigResourceDir()

    s = which('UnitTest');
    s = strrep(s, '/@UnitTest/UnitTest.m', '');
    AutoConfigResourceDir = fullfile(s, 'UnitTestTools', 'AutoConfigResources');
    
end