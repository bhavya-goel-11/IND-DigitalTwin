%% IND Digital Twin Demo (Script Version)
% This script illustrates the scaffold workflow:
% 1. Load config
% 2. Generate scenario
% 3. Collect metrics
% 4. Generate variations
%
addpath(genpath(fullfile(pwd,'src','matlab')));

configPath = 'configs/examples/delhi_sample_canonical.json';

%% Single Scenario Generation
out = generateScenarioFromConfig(configPath);

%% Metrics
metrics = collectMetrics(out);
fprintf('Feature counts:\n'); disp(metrics.featureCounts);
fprintf('Vehicle class counts:\n'); disp(metrics.vehicleClassCounts);
fprintf('Total vehicles: %d\n', metrics.totalVehicles);

%% Variation Set
varResults = generateScenarioSet(configPath);
fprintf('Generated %d scenario variants.\n', numel(varResults));

%% (Optional) Visualize first scenario
try
    plot(out.scenario);
catch ME
    warning('Plot failed: %s', ME.message);
end
