function out = generateScenarioFromConfig(configPath)
% generateScenarioFromConfig  End-to-end helper for single scenario.
%   out = generateScenarioFromConfig('configs/examples/delhi_sample_canonical.json')
%
% Steps:
%   1. Load config
%   2. Build base geometry (canonical for now)
%   3. Apply augmentation
%   4. Return struct with scenario + metadata

cfg = loadConfig(configPath);

% Step 2: geometry selection - OSM only
if ~strcmp(cfg.geometry.source, 'osm')
    error('Only OSM geometry source is supported. Use source: "osm"');
end
if ~isfield(cfg.geometry,'osmFile')
    error('geometry.osmFile required when source=="osm"');
end
[scenario, osmMeta] = buildScenarioFromOSM(cfg.geometry.osmFile); %#ok<NASGU>
% osmMeta will be attached to output struct later

% Step 3: augmentation
if exist('osmMeta','var')
    aug = augmentScenario(scenario, cfg, osmMeta);
else
    aug = augmentScenario(scenario, cfg);
end

% Step 4: traffic spawning (multi-class placeholder)
spawned = spawnTraffic(aug.scenario, cfg);
if isfield(cfg,'behaviorProfiles') && ~isempty(cfg.behaviorProfiles)
    spawned = applyBehaviorProfiles(spawned, cfg.behaviorProfiles);
end

out = struct();
out.config = cfg;
out.scenario = aug.scenario;
out.spawnedActors = spawned;
out.features = aug.appliedFeatures;
out.notes = aug.notes;
if exist('osmMeta','var')
    out.osmMeta = osmMeta;
end
end
