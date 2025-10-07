function setup_ind_digitaltwin_paths()
% setup_ind_digitaltwin_paths  Add all required paths for IND-DigitalTwin
%
% Call this function before using any IND-DigitalTwin functions to ensure
% all required paths are properly added to MATLAB's search path.
%
% Usage:
%   setup_ind_digitaltwin_paths();
%   out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');

% Find the repository root (assumes this function is in the root)
currentFile = mfilename('fullpath');
repoRoot = fileparts(currentFile);

% Add main source directory recursively
srcPath = fullfile(repoRoot, 'src', 'matlab');
if isfolder(srcPath)
    addpath(genpath(srcPath));
    fprintf('Added path: %s (recursive)\n', srcPath);
else
    error('Source directory not found: %s', srcPath);
end

% Explicitly add critical subdirectories
criticalPaths = {
    fullfile(srcPath, 'augmentation');
    fullfile(srcPath, 'behavior');
};

for i = 1:length(criticalPaths)
    if isfolder(criticalPaths{i})
        addpath(criticalPaths{i});
        fprintf('Added path: %s\n', criticalPaths{i});
    end
end

% Verify critical functions are now available
criticalFunctions = {
    'generateScenarioFromConfig';
    'augmentScenario';
    'buildScenarioFromOSM';
    'loadConfig';
    'spawnTraffic';
    'applyBehaviorProfiles';
    'plotAppliedFeatures';
    'placeFeatureAtCoordinate';
    'selectCoordinatesInteractively'
};

fprintf('\nFunction availability check:\n');
allAvailable = true;
for i = 1:length(criticalFunctions)
    if ~isempty(which(criticalFunctions{i}))
        fprintf('✓ %s\n', criticalFunctions{i});
    else
        fprintf('✗ %s (MISSING)\n', criticalFunctions{i});
        allAvailable = false;
    end
end

if allAvailable
    fprintf('\n✅ All critical functions are available!\n');
    fprintf('You can now use IND-DigitalTwin functions.\n\n');
else
    fprintf('\n❌ Some functions are missing. Check your installation.\n\n');
end

end