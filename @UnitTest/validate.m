% Main validation engine
function abortValidationSession = validate(obj, vScriptsToRunList)
    
    % get validation params
    validationParams = obj.validationParams;
    if (validationParams.verbosity > -1)
        fprintf('\n------------------------------------------------------------------------------------------------------------\n');
        fprintf('Running in ''%s'' mode with ''%s'' runtime hehavior and verbosity level = ''%s''.', validationParams.type, validationParams.onRunTimeError, UnitTest.validVerbosityLevels{validationParams.verbosity+2});
    end
    
    % Parse the scripts list to ensure it is valid
    obj.vScriptsList = obj.parseScriptsList(vScriptsToRunList);
    
    if (validationParams.verbosity > 1) 
        fprintf('\nWill validate %d scripts.', numel(obj.vScriptsList)); 
    end
    
    if (validationParams.verbosity > -1)
        fprintf('\n------------------------------------------------------------------------------------------------------------\n');
    end
    
    
    
    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    projectSpecificPreferences = getpref(theProjectName, 'projectSpecificPreferences');
    
    %Ensure that needed directories exist, and generate them if they do not
    abortValidationSession = obj.checkDirectories(projectSpecificPreferences);
    
    % reset currentValidationSessionResults
    obj.validationSessionRunTimeExceptions = [];
    
    % reset list of scripts with new validation data sets
    vScriptsListWithNewValidationDataSet = {};
    
    % Go through each entry
    scriptIndex = 0;

    while (scriptIndex < numel(obj.vScriptsList)) && (~abortValidationSession)
        
        scriptIndex = scriptIndex + 1;
        
        % get the current entry
        scriptListEntry = obj.vScriptsList{scriptIndex};
        
        % get the scriptName
        scriptName = scriptListEntry{1};
        
        % Determine script small name and sub-directory
        indices = strfind(scriptName, filesep);
        smallScriptName = scriptName(indices(end)+1:end-2);
        scriptSubDirectory = scriptName(indices(end-1)+1:indices(end)-1);
            
        % form a URL for it
        urlToScript =  sprintf('<a href="matlab: matlab.desktop.editor.openAndGoToFunction(which(''%s''),'''')">''%s''</a>', smallScriptName, smallScriptName);
        
        if (validationParams.verbosity > 0) 
            % print it in the command line
            fprintf('\n[%3d] %s\n', scriptIndex, urlToScript);
        end
        
        % get the scripRunParams
        if (numel(scriptListEntry) == 2)
            scriptRunParams = scriptListEntry{2};
            % make sure we do not generate plots in RUNTIME_ERRORS_ONLY mode
            if (strcmp(validationParams.type, 'RUNTIME_ERRORS_ONLY'))
                scriptRunParams.generatePlots = false;
            end
        else % Use default prefs
            scriptRunParams = [];
            
            if (strcmp(validationParams.type, 'RUNTIME_ERRORS_ONLY'))
                scriptRunParams.generatePlots = false;
            end
        end
               
        % Make sure script exists in the path
        if (exist(scriptName, 'file') == 2)
            % Construct path strings
            htmlDirectory                       = fullfile(obj.htmlDir, scriptSubDirectory, sprintf('%s_HTML', smallScriptName));
            fullLocalGroundTruthHistoryDataFile = fullfile(obj.fullValidationDataDir, scriptSubDirectory, sprintf('%s_FullGroundTruthDataHistory.mat', smallScriptName)); 
            fastLocalGroundTruthHistoryDataFile = fullfile(obj.fastValidationDataDir, scriptSubDirectory, sprintf('%s_FastGroundTruthDataHistory.mat', smallScriptName));
        else
            error('A file named ''%s'' does not exist in the path.', scriptName);
        end
   
        [localScriptDir,~,~] = fileparts(scriptName);

        % Initialize flags, reports, and validation data
        validationReport        = '';
        validationFailedFlag    = true;
        validationFundamentalFailureFlag = true;
        doFullValidationWhileInFastValidationMode = false;
        exceptionRaisedFlag     = true;
        validationData          = [];
        extraData               = [];
        
        
        if strcmp(validationParams.type, 'RUNTIME_ERRORS_ONLY')
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationFundamentalFailureFlag, validationData, extraData] = %s(scriptRunParams);', smallScriptName);
            
        elseif strcmp(validationParams.type, 'FAST')
            % Create fast validationData sub directory if it does not exist;
            fastValidationDirectoryExistedAlready = obj.generateDirectory(obj.fastValidationDataDir, scriptSubDirectory);
            
            if ((~fastValidationDirectoryExistedAlready) || (~exist(fastLocalGroundTruthHistoryDataFile, 'file')) || (~exist(fullLocalGroundTruthHistoryDataFile, 'file')))
                
                if (projectSpecificPreferences.generateGroundTruthDataIfNotFound)
                    
                    if (validationParams.verbosity > 4)
                        if  (~exist(fastLocalGroundTruthHistoryDataFile, 'file'))
                            fprintf(2,'\nValidation data file\n\t%s\ndoes not exist. Will generate new FAST and FULL data\n\t%s\n\t%s.\n',fastLocalGroundTruthHistoryDataFile, fastLocalGroundTruthHistoryDataFile, fullLocalGroundTruthHistoryDataFile);
                            fprintf(2,'Hit enter to proceed.');
                            pause
                        end
                        if  (~exist(fullLocalGroundTruthHistoryDataFile, 'file'))
                            fprintf(2,'\nValidation data file\n\t%s\ndoes not exist. Will generate new FAST and FULL data\n\t%s\n\t%s.\n',fullLocalGroundTruthHistoryDataFile,fastLocalGroundTruthHistoryDataFile, fullLocalGroundTruthHistoryDataFile);
                            fprintf(2,'Hit enter to proceed.');
                            pause
                        end
                    end
                    
                    % The FAST validation data set directory did not exist already, or the FAST validation data set itseld did not exist,
                    % Remove the FAST and the FULL validation data file for this script
                    system(sprintf('rm -f %s', fastLocalGroundTruthHistoryDataFile));
                    system(sprintf('rm -f %s', fullLocalGroundTruthHistoryDataFile));
                    % And force a full validation, which will generate new data
                    doFullValidationWhileInFastValidationMode = true;
                    % Generate the full validation data directory, in case it does not exist
                    obj.generateDirectory(obj.fullValidationDataDir, scriptSubDirectory);
                end
            end
            
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationFundamentalFailureFlag, validationData, extraData] = %s(scriptRunParams);', smallScriptName);
            
        elseif strcmp(validationParams.type, 'FULL')
            
            % Create full validationData sub directory if it does not exist;
            fullValidationDirectoryExistedAlready = obj.generateDirectory(obj.fullValidationDataDir, scriptSubDirectory);
            
            if ((~fullValidationDirectoryExistedAlready) || (~exist(fullLocalGroundTruthHistoryDataFile, 'file')) || (~exist(fastLocalGroundTruthHistoryDataFile, 'file')))
                
                if (projectSpecificPreferences.generateGroundTruthDataIfNotFound)
                    
                    if (validationParams.verbosity > 4)
                        if  (~exist(fastLocalGroundTruthHistoryDataFile, 'file'))
                            fprintf(2,'\nValidation data file\n\t%s\ndoes not exist. Will generate new FAST and FULL data\n\t%s\n\t%s.\n',fastLocalGroundTruthHistoryDataFile, fastLocalGroundTruthHistoryDataFile, fullLocalGroundTruthHistoryDataFile);
                            fprintf(2,'Hit enter to proceed.');
                            pause
                        end
                        if  (~exist(fullLocalGroundTruthHistoryDataFile, 'file'))
                            fprintf(2,'\nValidation data file\n\t%s\ndoes not exist. Will generate new FAST and FULL data\n\t%s\n\t%s.\n',fullLocalGroundTruthHistoryDataFile,fastLocalGroundTruthHistoryDataFile, fullLocalGroundTruthHistoryDataFile);
                            fprintf(2,'Hit enter to proceed.');
                            pause
                        end
                    end
                    
                    % The FULL validation data set directory did not exist already, or the FULL validation data set itself did not exist.
                    % Remove the FAST and the FULL validation data file for this script
                    system(sprintf('rm -f %s', fastLocalGroundTruthHistoryDataFile));
                    system(sprintf('rm -f %s', fullLocalGroundTruthHistoryDataFile));
                    % Generate the fast validation data directory, in case it does not exist
                    obj.generateDirectory(obj.fastValidationDataDir, scriptSubDirectory);
               end
            end

            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationFundamentalFailureFlag, validationData, extraData] = %s(scriptRunParams);', smallScriptName);
            
        elseif strcmp(validationParams.type, 'PUBLISH')
            
            % Create full validationData sub directory if it does not exist;
            fullValidationDirectoryExistedAlready = obj.generateDirectory(obj.fullValidationDataDir, scriptSubDirectory);
            
            if ((~fullValidationDirectoryExistedAlready) || (~exist(fullLocalGroundTruthHistoryDataFile, 'file')) || (~exist(fastLocalGroundTruthHistoryDataFile, 'file')))
                if (projectSpecificPreferences.generateGroundTruthDataIfNotFound)
                    % The FULL validation data set directory did not exist already, or the FULL validation data set itself did not exist.
                    % remove the FAST and the FULL validation data file for this script
                    system(sprintf('rm -f %s', fastLocalGroundTruthHistoryDataFile));
                    system(sprintf('rm -f %s', fullLocalGroundTruthHistoryDataFile));
                    % Generate the fast validation data directory, in case it does not exist
                    obj.generateDirectory(obj.fastValidationDataDir, scriptSubDirectory);
                end
            end
            
            
            % Create HTML sub directory if it does not exist;
            obj.generateDirectory(obj.htmlDir, scriptSubDirectory);
            % Critical: Assign the params variable to the base workstation
            assignin('base', 'scriptRunParams', scriptRunParams);
            % Form publish options struct
            command = sprintf('[validationReport, validationFailedFlag, validationFundamentalFailureFlag, validationData, extraData] = %s(scriptRunParams);', smallScriptName);
            options = struct(...
                'codeToEvaluate', ['scriptRunParams;', char(10), sprintf('%s',command), char(10)'], ...
                'evalCode',     true, ...
                'showCode',     true, ...
                'catchError',   false, ...
                'outputDir',    htmlDirectory ...
            );
            % Run script via MATLAB's publish method
            commandString = sprintf(' publish(''%s'', options);', smallScriptName);
        end
        
        % Form the try-catch command 
        if (strcmp(validationParams.onRunTimeError, 'catchExceptionAndContinue'))
            command = sprintf('try \n\t%s \n\t exceptionRaisedFlag = false;  \ncatch err \n\t exceptionRaisedFlag = true;\n\t validationReport{1} = {sprintf(''exception raised (and caught) with message: %%s'', err.message), true, false};  \nend', commandString);
        else
            command = sprintf('try \n\t%s  \n\t exceptionRaisedFlag = false; \ncatch err \n\t exceptionRaisedFlag = true;\n\t validationReport{1} = {sprintf(''exception raised with message: %%s'', err.message), true, false};  \n\t rethrow(err);  \nend', commandString);
        end
        
        if (validationParams.verbosity > 5)
            fprintf('\nRunning with ');
            eval('scriptRunParams');
        end
        
        if (validationParams.verbosity > 4)
           fprintf('\nExecuting:\n%s\n', command); 
        end
        
        % save current dir
        currentDir = pwd();
        
        % cd to script directory
        cd(localScriptDir);
        
        % Run the try-catch command and capture the output in T
        T = evalc(command); 
        
        % back to current dir
        cd(currentDir);
        
        % Update currentValidationSeesionResults
        obj.validationSessionRunTimeExceptions(scriptIndex) = exceptionRaisedFlag;
        
        if (strcmp(validationParams.type, 'PUBLISH'))
            if (exceptionRaisedFlag)
                validationFailedFlag = true;
                validationFundamentalFailureFlag = false;
                validationReport = '';
                if (strcmp(validationParams.onRunTimeError,'rethrowExceptionAndAbort'))
                    abortValidationSession = true;
                    break;
                end
            else
                % Extract the value of the variables 'validationReport' in the MATLAB's base workspace and capture them in the corresponding local variable 'validationReport'
                validationReport                 = evalin('base', 'validationReport');
                validationFailedFlag             = evalin('base', 'validationFailedFlag');
                validationFundamentalFailureFlag = evalin('base', 'validationFundamentalFailureFlag');
                validationData                   = evalin('base', 'validationData');
                extraData                        = evalin('base', 'extraData');
            end
        else
            if (exceptionRaisedFlag)
                validationFailedFlag             = validationReport{1}{2};
                validationFundamentalFailureFlag = validationReport{1}{3};
            end
        end

        if (validationParams.verbosity > 0) 
            % Update the command line output
            if (validationFailedFlag)
                if (validationFundamentalFailureFlag)
                    fprintf(2, '\tInternal validation  : FUNDAMENTAL FAILURE !!\n');
                else
                    fprintf(2, '\tInternal validation  : FAILED\n');
                end
            else
               fprintf('\tInternal validation  : PASSED\n'); 
            end
            
            if (exceptionRaisedFlag)
               fprintf(2, '\tRun-time status      : exception raised\n');
            else
               fprintf('\tRun-time status      : no exception raised\n'); 
            end
        end
        
        if (~strcmp(validationParams.type, 'RUNTIME_ERRORS_ONLY')) 
            if ( (strcmp(validationParams.type, 'FAST'))  && (~validationFailedFlag) && (~exceptionRaisedFlag) )
                % 'FAST' mode validation
                abortValidationSession = doFastValidation(obj, fastLocalGroundTruthHistoryDataFile, validationData, projectSpecificPreferences, smallScriptName);
                if (abortValidationSession == false) && (doFullValidationWhileInFastValidationMode)
                    if (validationParams.verbosity > 1) 
                        fprintf('\t---------------------------------------------------------------------------------------------------------------------------------\n');
                    end
                    % 'FULL' mode validation
                    abortValidationSession = doFullValidation(obj, fullLocalGroundTruthHistoryDataFile, validationData, extraData, projectSpecificPreferences, smallScriptName);
                end
            end
        
            if ( (strcmp(validationParams.type, 'FULL')) && (~validationFailedFlag) && (~exceptionRaisedFlag) )
                % 'FAST' mode validation
                abortValidationSession = doFastValidation(obj, fastLocalGroundTruthHistoryDataFile, validationData, projectSpecificPreferences, smallScriptName);
                if (abortValidationSession == false)
                    if (validationParams.verbosity > 1) 
                        fprintf('\t---------------------------------------------------------------------------------------------------------------------------------\n');
                    end
                    % 'FULL' mode validation
                    abortValidationSession = doFullValidation(obj, fullLocalGroundTruthHistoryDataFile, validationData, extraData, projectSpecificPreferences, smallScriptName);
                end
            end
            
            if ( (strcmp(validationParams.type, 'PUBLISH')) && (~validationFailedFlag) && (~exceptionRaisedFlag) )
                % 'FAST' mode validation
                abortValidationSession = doFastValidation(obj, fastLocalGroundTruthHistoryDataFile, validationData, projectSpecificPreferences, smallScriptName);
                if (abortValidationSession == false)
                    if (validationParams.verbosity > 1) 
                        fprintf('\t---------------------------------------------------------------------------------------------------------------------------------\n');
                    end
                    % 'FULL' mode validation
                    abortValidationSession = doFullValidation(obj, fullLocalGroundTruthHistoryDataFile, validationData, extraData, projectSpecificPreferences, smallScriptName); 

                    % Construct sectionData for github wiki
                    sectionName = scriptSubDirectory;
                    % update sectionData map
                    s = {};
                    if (isKey(obj.sectionData,sectionName ))
                        s = obj.sectionData(sectionName);
                        s{numel(s)+1} = scriptName;
                    else
                        s{1} = scriptName; 
                    end
                    obj.sectionData(sectionName) = s;

                    if (validationParams.verbosity > 1) 
                        fprintf('\tReport published in  : ''%s''\n', htmlDirectory);
                    end
                end
            end    
        end  % validationParams.type != 'RUNTIME_ERRORS_ONLY'      
        
        
        if (validationParams.verbosity > 1) && (~strcmp(validationParams.type, 'RUNTIME_ERRORS_ONLY'))
            UnitTest.printValidationReport(validationReport); 
        end
        
        % Make sure figs are rendered at the conclusion of the script validation
        drawnow;
        pause(0.01);
        
    end % scriptIndex
    
    % Close any remaining non-data mismatch figures
    if (~isempty(scriptRunParams)) && (isfield(scriptRunParams, 'closeFigsOnInit'))
        closeFigsOnExit = scriptRunParams.closeFigsOnInit;
    else
        closeFigsOnExit = getpref(theProjectName, 'closeFigsOnInit');
    end

    if (closeFigsOnExit)
       UnitTest.closeAllNonDataMismatchFigures(); 
    end
    
    % cd to validation root dir
    cd(obj.rootDir);
end



function cancelRun = doFastValidation(obj, fastLocalGroundTruthHistoryDataFile, validationData, projectSpecificPreferences, smallScriptName)

    cancelRun = false;
    
    validationParams = obj.validationParams;
    groundTruthFastValidationFailed = false;
    
    if (~isfield(validationData, 'hashData'))
        if (validationParams.verbosity > 1) 
            fprintf('\tNote (*)             : script does not store any validation data.\n');
        end
        validationData.hashData = struct();
    end
    
    % Generate SHA256 hash from the validationData.hashData
    % substruct, which is a truncated copy of the data to 12-decimal digits
    hashSHA25 = obj.generateSHA256Hash(validationData.hashData);

    % Load and check value stored in LocalGroundTruthHistoryDataFile 
    dataFileName = fastLocalGroundTruthHistoryDataFile;
    forceGenerateGroundTruth = false;
            
    if (exist(dataFileName, 'file') == 2)
        % Ground truth data set for this file exists. So use it.
        [groundTruthValidationData, ~, groundTruthTime, hostInfo] = obj.importGroundTruthData(dataFileName);
        if (validationParams.verbosity > 3)
           fprintf('\tGround truth  file   : %s\n', dataFileName); 
        end
        
        % Compare validation data
        if (strcmp(groundTruthValidationData, hashSHA25))
            if (validationParams.verbosity > 0) 
                fprintf('\tFast validation      : PASSED against ground truth data of %s.\n', groundTruthTime);
                if (validationParams.verbosity > 2) 
                    fprintf('\t > Ground truth info : %30s / %s, MATLAB %s by ''%s''\n', hostInfo.computerAddress, hostInfo.computer, hostInfo.matlabVersion, hostInfo.userName);
                    fprintf('\t > Local host info   : %30s / %s, MATLAB %s by ''%s''\n', obj.hostInfo.computerAddress, obj.hostInfo.computer, obj.hostInfo.matlabVersion, obj.hostInfo.userName);
                end
            end
            if (validationParams.verbosity > 2) 
                fprintf('\tData hash key        : %s\n', hashSHA25);
            end
            groundTruthFastValidationFailed = false;
        else
            if (validationParams.verbosity > 0) 
                fprintf(2,'\tFast validation      : FAILED against ground truth data of %s.\n', groundTruthTime);
                if (validationParams.verbosity > 2) 
                    fprintf(2,'\t > Ground truth info : %30s / %s, MATLAB %s by ''%s''\n', hostInfo.computerAddress, hostInfo.computer, hostInfo.matlabVersion, hostInfo.userName);
                    fprintf(2,'\t > Local host info   : %30s / %s, MATLAB %s by ''%s''\n', obj.hostInfo.computerAddress, obj.hostInfo.computer, obj.hostInfo.matlabVersion, obj.hostInfo.userName);
                end
                fprintf(2,'\tDataHash-this run    : %s\n', hashSHA25);
                fprintf(2,'\tDataHash-groundTruth : %s\n', groundTruthValidationData);
            end
            groundTruthFastValidationFailed = true;
        end
    else
        % Ground truth data set for this file does not exist.
        if (obj.forceGenerateFastGroundTruthForAllScripts)
            forceGenerateGroundTruth = true;
        else
            % Check whether the user specified to generate ground truth
            if (projectSpecificPreferences.generateGroundTruthDataIfNotFound)
                [forceGenerateGroundTruth, cancelRun] = obj.queryUserWhetherToReallyGenerateGroundTruth('FAST', smallScriptName);
            else
                forceGenerateGroundTruth = false;
            end
        end
    
        if (forceGenerateGroundTruth) 
            if (validationParams.verbosity > 0)
                fprintf('\tFast validation      : no ground truth dataset exists. Generating one. \n');
            end
        else
            fprintf(2,'\tFast validation      : FAILED because a ''FAST'' ground truth data set for this script was not found.\n');
            groundTruthFastValidationFailed = true; 
        end
    end
           
    if (~groundTruthFastValidationFailed)
        % save/append to LocalGroundTruthHistoryDataFile 
        if (forceGenerateGroundTruth)
            dataFileName = fastLocalGroundTruthHistoryDataFile;
            if (exist(dataFileName, 'file') == 2)
                if (validationParams.verbosity > 1) 
                    fprintf('\tSHA-256 hash key     : %s, appended to existing ground truth history (''%s'')\n', hashSHA25, dataFileName);
                end
            else
                if (validationParams.verbosity > 1) 
                    fprintf('\tSHA-256 hash key     : %s, generated new ground truth data set (''%s'')\n', hashSHA25, dataFileName);
                end
            end
            obj.exportData(dataFileName, hashSHA25, struct());
        end  % if (forceGenerateGroundTruth)
    end % (~groundTruthFastValidationFailed)             
end


function cancelRun = doFullValidation(obj, fullLocalGroundTruthHistoryDataFile, validationData, extraData, projectSpecificPreferences, smallScriptName)

    cancelRun = false;
    
    validationParams = obj.validationParams;
    groundTruthFullValidationFailed = false;
    
    % Load and check value stored in LocalGroundTruthHistoryDataFile 
    dataFileName = fullLocalGroundTruthHistoryDataFile;
    forceGenerateGroundTruth = false;

    if (isempty(fieldnames(validationData)))
        if (validationParams.verbosity > 1) 
            fprintf('\tNote (*)             : script does not store any validation data.\n');
        end
    end

    % hashData not needed for FULL validation, so remove it so we do not compare its data
    if (isfield(validationData, 'hashData'))
        validationData = rmfield(validationData, 'hashData');
    end
                
    if (exist(dataFileName, 'file') == 2)
        % Ground truth data set for this file exists. So use it.
        [groundTruthValidationData, groundTruthExtraData, groundTruthTime, hostInfo] = obj.importGroundTruthData(dataFileName);
        if (validationParams.verbosity > 3)
           fprintf('\tGround truth  file   : %s\n', dataFileName); 
        end
        
        % Compare validation data
        [structsAreSimilarWithinSpecifiedTolerance, mismatchReport] = ...
            obj.structsAreSimilar(groundTruthValidationData, validationData);

        if (structsAreSimilarWithinSpecifiedTolerance)
            if (validationParams.verbosity > 0) 
                fprintf('\tFull validation      : PASSED against ground truth data of %s.\n', groundTruthTime);
                if (validationParams.verbosity > 2) 
                    fprintf('\t > Ground truth info : %30s / %s, MATLAB %s by ''%s''\n', hostInfo.computerAddress, hostInfo.computer, hostInfo.matlabVersion, hostInfo.userName);
                    fprintf('\t > Local host info   : %30s / %s, MATLAB %s by ''%s''\n', obj.hostInfo.computerAddress, obj.hostInfo.computer, obj.hostInfo.matlabVersion, obj.hostInfo.userName);
                end
            end
            groundTruthFullValidationFailed = false;
        else
            if (validationParams.verbosity > 0) 
                fprintf(2,'\tFull validation      : FAILED against ground truth data of %s.\n', groundTruthTime);
                if (validationParams.verbosity > 2) 
                    fprintf(2,'\t > Ground truth info : %-30s / %s, MATLAB %s by ''%s''\n', hostInfo.computerAddress, hostInfo.computer, hostInfo.matlabVersion, hostInfo.userName);
                    fprintf(2,'\t > Local host info   : %-30s / %s, MATLAB %s by ''%s''\n', obj.hostInfo.computerAddress, obj.hostInfo.computer, obj.hostInfo.matlabVersion, obj.hostInfo.userName);
                end
            end
            groundTruthFullValidationFailed = true;

            % print info about mismatched fields
            if (validationParams.verbosity > 0) 
                for k = 1:numel(mismatchReport)
                    fprintf(2,'\t[data mismatch %2d]   : %s\n ', k, char(mismatchReport{k}));
                end
            end
        end

        % extra data
        if (validationParams.verbosity > 3) 
            if (isempty(fieldnames(extraData)))
                fprintf('\tNote (*)             : script does not store any extra data.\n');
            end 
        end
    else
        % Ground truth data set for this file does not exist.
        if (obj.forceGenerateFullGroundTruthForAllScripts)
            forceGenerateGroundTruth = true;
        else
            % Check whether the user specified to generate ground truth
            if (projectSpecificPreferences.generateGroundTruthDataIfNotFound)
                [forceGenerateGroundTruth, cancelRun] = obj.queryUserWhetherToReallyGenerateGroundTruth('FULL', smallScriptName);
            else
                forceGenerateGroundTruth = false;
            end
        end
        
        if (forceGenerateGroundTruth)
            if (validationParams.verbosity > 0)
                fprintf('\tFull validation      : no ground truth dataset exists. Generating one. \n');
            end
            
            if (validationParams.verbosity > 3) 
                if (isempty(fieldnames(extraData)))
                    fprintf('\tNote (*)             : script does not store any extra data.\n');
                end
            end
        else
            fprintf(2,'\tFull validation      : FAILED because a ''FULL'' ground truth data set for this script was not found.\n');
            fprintf(2,'\tFull validation      : You can request a ''FULL'' ground truth data set by emailing cottaris@sas.upenn.edu.\n');
            groundTruthFullValidationFailed = true; 
        end

        
    end

    if (~groundTruthFullValidationFailed) 
        % save/append to LocalGroundTruthHistoryDataFile 
        if (forceGenerateGroundTruth)
            dataFileName = fullLocalGroundTruthHistoryDataFile;
            if (exist(dataFileName, 'file') == 2)
                if (validationParams.verbosity > 1) 
                    fprintf('\tFull validation data : appended to existing ground truth history (''%s'') \n', dataFileName);
                end
            else
                if (validationParams.verbosity > 1) 
                    fprintf('\tFull validation data : generated new ground truth data set (''%s'') \n', dataFileName);
                end
            end
            obj.exportData(dataFileName, validationData, extraData);
        end  % if (forceGenerateGroundTruth)
    end % (~groundTruthFullValidationFailed)        
end