function actors = spawnTraffic(scenario, config)
% spawnTraffic  Create vehicles according to trafficDemand arrivalStreams.
%   actors = spawnTraffic(scenario, cfg)
% For each arrival stream:
%   - Generate Poisson arrival times (ratePerHour)
%   - For each time, sample vehicle class from vehicleClassMix
%   - Create vehicle object positioned initially at stream entry point
% Entry positioning heuristic (scaffold):
%   - Uses first road segment far endpoint as spawn for all (placeholder)

actors = struct('vehicle', {}, 'meta', {});

if ~isfield(config,'trafficDemand') || ~isfield(config.trafficDemand,'arrivalStreams')
    return;
end

streams = config.trafficDemand.arrivalStreams;
T = config.trafficDemand.timeHorizon;

% Basic selection of spawn reference point
spawnRef = [0 0 0];
try
    rs = scenario.RoadSegments; %#ok<PROPLC>
    if ~isempty(rs)
        c = rs(1).RoadCenters; %#ok<PROP>
        spawnRef = c(1,1:3);
    end
end

for s = 1:numel(streams)
    entry = streams(s);
    rate = entry.ratePerHour;
    if rate <= 0, continue; end
    % Poisson process generation
    t = 0; times = [];
    while t < T
        headway = -log(rand)*3600/rate; % seconds
        t = t + headway;
        if t < T
            times(end+1) = t; %#ok<AGROW>
        end
    end
    classes = fieldnames(entry.vehicleClassMix);
    weights = cellfun(@(fn) entry.vehicleClassMix.(fn), classes);
    weights = weights/sum(weights);

    for i=1:numel(times)
        vClass = classes{find(rand <= cumsum(weights),1,'first')};
        % Create vehicle
    veh = vehicle(scenario,'ClassID',1,'Position',spawnRef,'Name',sprintf('%s_%d',vClass,i));
    meta = struct('stream',entry.entryId,'time',times(i),'class',vClass);
    actors(end+1) = struct('vehicle', veh, 'meta', meta); %#ok<AGROW>
    end
end

end
