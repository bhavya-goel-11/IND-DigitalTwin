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

% Step 2: geometry selection
switch cfg.geometry.source
    case 'canonicalTemplate'
        [scenario, ego] = canonical_junction_generator(); %#ok<ASGLU>
    case 'osm'
        if ~isfield(cfg.geometry,'osmFile')
            error('geometry.osmFile required when source=="osm"');
        end
        scenario = buildScenarioFromOSM(cfg.geometry.osmFile);
    otherwise
        error('Unknown geometry source: %s', cfg.geometry.source);
end

% Step 3: augmentation
aug = augmentScenario(scenario, cfg);

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
end
