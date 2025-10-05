%% run_ind_digitaltwin_demo
% One-click demo runner for IND-DigitalTwin.
% Usage: Open this file in MATLAB (repo root) and press Run.
% It will:
%  1. Add required paths
%  2. Verify core functions
%  3. Generate scenario from sample config
%  4. Plot scenario + feature overlay
%  5. Display metrics
%  6. Generate variation set & export package
%
% No manual path edits required.

clear; clc;
fprintf('=== IND-DigitalTwin Demo Start ===\n');
repoRoot = fileparts(mfilename('fullpath'));
cd(repoRoot);

%% Add paths recursively
srcPath = fullfile(repoRoot,'src','matlab');
if ~isfolder(srcPath)
    error('Source path missing: %s', srcPath);
end
addpath(genpath(srcPath));
fprintf('[Path] Added: %s (recursive)\n', srcPath);

%% Verify core functions
coreFns = {'generateScenarioFromConfig','augmentScenario','spawnTraffic', ...
           'applyBehaviorProfiles','collectMetrics','plotAppliedFeatures', ...
           'prepareHackathonPackage'};
missing = false;
for i=1:numel(coreFns)
    if isempty(which(coreFns{i}))
        fprintf(2,'[MISSING] %s\n', coreFns{i}); missing = true; else
        fprintf('[OK] %s\n', coreFns{i});
    end
end
if missing
    error('One or more required functions are missing from path. Abort.');
end

%% Configuration path
configPath = fullfile(repoRoot,'configs','examples','delhi_sample_canonical.json');
if ~isfile(configPath)
    error('Config file not found: %s', configPath);
end
fprintf('[Config] Using %s\n', configPath);

%% Generate Single Scenario
tic;
out = generateScenarioFromConfig(configPath);
genTime = toc;
fprintf('[Scenario] Generated in %.3f s\n', genTime);

%% Plot Scenario & Features
try
    fig = figure('Name','IND-DigitalTwin Scenario');
    plot(out.scenario); hold on; plotAppliedFeatures(out.scenario, out.features);
    title(sprintf('Scenario: %s', out.config.id),'Interpreter','none');
catch ME
    warning('Plot failed: %s', ME.message);
end

%% Metrics
metrics = collectMetrics(out);
fprintf('--- Feature Counts ---\n'); disp(metrics.featureCounts);
fprintf('--- Vehicle Class Counts ---\n'); disp(metrics.vehicleClassCounts);
fprintf('Total Vehicles: %d\n', metrics.totalVehicles);

%% Variation Generation
varStart = tic;
variants = generateScenarioSet(configPath);
varTime = toc(varStart);
fprintf('[Variation] Generated %d variants in %.3f s\n', numel(variants), varTime);

%% Packaging (reports, plot, summary)
distDir = fullfile(repoRoot,'dist');
pkg = prepareHackathonPackage(configPath, distDir); %#ok<NASGU>
fprintf('[Package] Artifacts written to %s\n', distDir);

%% Summary Table
fprintf('\n=== Summary ===\n');
fprintf('Generation Time (s): %.3f\n', genTime);
fprintf('Variants: %d\n', numel(variants));
fprintf('Feature Types: %s\n', strjoin(unique({out.features.type}),', '));

fprintf('=== Demo Complete ===\n');
