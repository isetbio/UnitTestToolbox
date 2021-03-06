% Method that prints all available validation scripts and asks the user to select one for validation.
%
% Optional key/value pairs
%  'prompt' - string (default 'Enter script no. to validate/publish').
%     Selection prompt string

function scriptToValidate = selectScriptFromExistingOnes(varargin)

p = inputParser;
p.addParameter('prompt','Enter script no. to validate/publish',@ischar);
p.parse(varargin{:});

listingScript = UnitTest.getPref('listingScript');
validationRootDir = UnitTest.getPref('validationRootDir');

vScriptsList = eval(listingScript);

totalScriptIndex = 0;
scriptToValidate = '';

dotsNum = 55;

for scriptDirectoryIndex = 1:numel(vScriptsList)
    % get the current entry
    scriptListEntry = vScriptsList{scriptDirectoryIndex};
    % get the directory name
    scriptDirectoryName = scriptListEntry{1};
    if (exist(scriptDirectoryName, 'dir') ~= 7)
        error('A directory named ''%s'' does not exist in the path.', scriptDirectoryName);
    end
    
    scriptRunParams = [];
    % get the contents of the directory
    dirToList = fullfile(scriptDirectoryName, '*.m');
    scriptsListInCurrentDirectory = dir(dirToList);
    
    for scriptIndex = 1:numel(scriptsListInCurrentDirectory)
        totalScriptIndex = totalScriptIndex + 1;
        if (totalScriptIndex == 1)
            fprintf('\n\n---------------------------------------------------------------------------\n');
            fprintf('Available validation scripts                              Script no. \n');
            fprintf('---------------------------------------------------------------------------\n');
        end
        if (scriptIndex == 1)
            fprintf('<strong>%s</strong>\n', strrep(scriptDirectoryName, fullfile(validationRootDir,  'scripts/'), ''));
        end
        scriptName{totalScriptIndex} = fullfile(scriptDirectoryName,scriptsListInCurrentDirectory(scriptIndex).name);
        dots = '';
        for k = 1:dotsNum-numel(scriptsListInCurrentDirectory(scriptIndex).name)
            dots(k) = '.';
        end
        fprintf('\t%s %s %3d\n',  scriptsListInCurrentDirectory(scriptIndex).name, dots,totalScriptIndex);
    end
end
selectedScriptIndex = input(sprintf(['\n' p.Results.prompt ' [%d-%d]: '], 1, totalScriptIndex));
if (isempty(selectedScriptIndex)) || (~isnumeric(selectedScriptIndex))
    error('input must be a numeral');
elseif (selectedScriptIndex <= 0) || (selectedScriptIndex > totalScriptIndex)
    error('input must be in range [%d .. %d]', 1, totalScriptIndex);
else
    scriptToValidate = scriptName{selectedScriptIndex};
end
end