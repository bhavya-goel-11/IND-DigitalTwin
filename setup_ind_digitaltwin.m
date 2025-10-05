function setup_ind_digitaltwin()
% setup_ind_digitaltwin  Add required paths and verify core functions.
%   Call once from repository root:
%       setup_ind_digitaltwin
%
% This script:
%   1. Determines repo root based on this file's location.
%   2. Adds src/matlab and all subfolders (including canonical & behavior etc.).
%   3. Verifies presence of key functions.
%   4. Warns if any are missing.
%
% If a function is reported missing, confirm you are on the project root
% or re-clone to ensure all files exist.

fprintf('[IND-DigitalTwin] Initializing environment...\n');

thisFile = mfilename('fullpath');
repoRoot = fileparts(thisFile);
fprintf('Repo root inferred: %s\n', repoRoot);

srcPath = fullfile(repoRoot,'src','matlab');
if ~isfolder(srcPath)
    error('Expected folder not found: %s', srcPath);
end

addpath(genpath(srcPath));
fprintf('Added path (recursive): %s\n', srcPath);

coreFns = { ...
    'generateScenarioFromConfig', ...
    'augmentScenario', ...
    'spawnTraffic', ...
    'applyBehaviorProfiles', ...
    'collectMetrics', ...
    'plotAppliedFeatures', ...
    'prepareHackathonPackage'};

missing = {};
for i = 1:numel(coreFns)
    fn = coreFns{i};
    w = which(fn);
    if isempty(w)
        fprintf(2,'[MISSING] %s (not found on path)\n', fn);
        missing{end+1} = fn; %#ok<AGROW>
    else
        fprintf('[OK] %s -> %s\n', fn, w);
    end
end

if isempty(missing)
    fprintf('[IND-DigitalTwin] Setup complete. All core functions located.\n');
else
    fprintf(2,'[IND-DigitalTwin] Setup finished with missing functions above.\n');
    fprintf(2,'Check that you cloned the full repository and did not rename folders.\n');
end

end
