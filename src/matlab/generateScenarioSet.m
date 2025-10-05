function results = generateScenarioSet(configPath)
% generateScenarioSet  Produce variation set based on config.variation spec.
%   results = generateScenarioSet('configs/examples/delhi_sample_canonical.json')
%
% If config.variation.count > 1, reseeds RNG and regenerates scenario.

baseCfg = loadConfig(configPath);
count = 1; seed = [];
if isfield(baseCfg,'variation')
    if isfield(baseCfg.variation,'count'); count = max(1, baseCfg.variation.count); end
    if isfield(baseCfg.variation,'seed'); seed = baseCfg.variation.seed; end
end

results = cell(count,1);
for i=1:count
    if ~isempty(seed)
        rng(seed + i - 1);
    end
    out = generateScenarioFromConfig(configPath);
    out.variantIndex = i;
    results{i} = out;
end

end
