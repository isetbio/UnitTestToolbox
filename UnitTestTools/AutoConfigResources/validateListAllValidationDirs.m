function vScriptsList = validateListAllValidationDirs
%
% This encapsulates a vull list of our validation directories, so we only
% need to update it in one place.
% 
% Doesn't list the example scripts, and doesn't override any default prefs.
%

% List of script directories to validate. Each entry contains a cell array with 
% with a validation script directory and an optional struct with
% prefs that override the corresponding validation prefs.
% At the moment only the 'generatePlots' pref can be overriden.
%        

% Get rootDir
rootDir = UnitTest.getPref('validationRootDir');

vScriptsList = {...
        {fullfile(rootDir, 'scripts', 'category1scripts')} ... 
        {fullfile(rootDir, 'scripts', 'category1scripts')} ...
    };
    
end