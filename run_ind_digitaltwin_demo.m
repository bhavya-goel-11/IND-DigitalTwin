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
% Default now points to OSM-based demo config using the updated sample_map.osm.
% To swap to ANY other OSM file:
%   1. Place your file in data/osm/ (e.g. data/osm/my_area.osm)
%   2. Duplicate configs/examples/delhi_osm_demo.json
%   3. Change geometry.osmFile to your new path
%   4. (Optional) Adjust microFeatures counts / placement rules
%   5. Re-run this script
configPath = fullfile(repoRoot,'configs','examples','delhi_osm_demo.json');
if ~isfile(configPath)
    error('Config file not found: %s', configPath);
end
fprintf('[Config] Using (OSM) %s\n', configPath);

%% Generate Single Scenario
tic;
out = generateScenarioFromConfig(configPath);
genTime = toc;
fprintf('[Scenario] Generated in %.3f s\n', genTime);

%% Debug OSM Import
if isfield(out, 'osmMeta')
    fprintf('[OSM Debug] Roads created: %d\n', out.osmMeta.roadCreatedCount);
    if isfield(out.osmMeta, 'highwayTypeCounts')
        keys = out.osmMeta.highwayTypeCounts.keys;
        for i = 1:length(keys)
            fprintf('[OSM Debug] %s roads: %d\n', keys{i}, out.osmMeta.highwayTypeCounts(keys{i}));
        end
    end
    fprintf('[OSM Debug] Node coordinate range: X[%.1f, %.1f], Y[%.1f, %.1f]\n', ...
        min(out.osmMeta.nodeXY(:,1)), max(out.osmMeta.nodeXY(:,1)), ...
        min(out.osmMeta.nodeXY(:,2)), max(out.osmMeta.nodeXY(:,2)));
end

%% Plot Scenario & Features
try
    fig = figure('Name','IND-DigitalTwin Scenario', 'Position', [100 100 1000 800]);
    
    % Plot scenario with enhanced visibility
    hScenario = plot(out.scenario);
    
    % Enhance road appearance if available
    if ~isempty(hScenario) && length(hScenario) > 0
        for i = 1:length(hScenario)
            if isprop(hScenario(i), 'LineWidth')
                hScenario(i).LineWidth = 2.5; % Thicker road lines
            end
            if isprop(hScenario(i), 'Color')
                hScenario(i).Color = [0.2 0.2 0.2]; % Dark gray roads
            end
        end
    end
    
    hold on; 
    plotAppliedFeatures(out.scenario, out.features);
    
    % Improved axis and display
    axis equal;
    grid on;
    xlabel('X (meters)');
    ylabel('Y (meters)');
    title(sprintf('Scenario: %s\nOSM Roads: %d created', out.config.id, out.osmMeta.roadCreatedCount), 'Interpreter','none');
    
    % Set axis limits based on scenario bounds if possible
    if isfield(out, 'osmMeta') && isfield(out.osmMeta, 'nodeXY')
        xy = out.osmMeta.nodeXY;
        if ~isempty(xy)
            margin = 20; % 20m margin
            xlim([min(xy(:,1))-margin, max(xy(:,1))+margin]);
            ylim([min(xy(:,2))-margin, max(xy(:,2))+margin]);
        end
    end
    
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
if ~isempty(out.features)
    fprintf('Feature Types: %s\n', strjoin(unique({out.features.type}),', '));
else
    fprintf('Feature Types: (none placed)\n');
end

fprintf('=== Demo Complete ===\n');
%% Expose output struct for interactive exploration
try
    assignin('base','ind_digitaltwin_lastRun', out);
    fprintf('[Export] Scenario output assigned to base variable ind_digitaltwin_lastRun\n');
catch ME
    warning('Could not assign output to base workspace: %s', ME.message);
end
