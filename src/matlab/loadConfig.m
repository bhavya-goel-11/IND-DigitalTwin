function cfg = loadConfig(jsonPath)
% loadConfig Load and minimally validate scenario config JSON.
%   cfg = loadConfig(path)

arguments
    jsonPath (1,1) string
end

if ~isfile(jsonPath)
    error('Config file not found: %s', jsonPath);
end
raw = fileread(jsonPath);
cfg = jsondecode(raw);

% Minimal required fields
must = {"id","geometry","trafficDemand"};
for i = 1:numel(must)
    fieldName = must{i};
    if ~isfield(cfg, fieldName)
        error('Missing required field: %s', fieldName);
    end
end
end
