function actors = applyBehaviorProfiles(actors, profiles)
% applyBehaviorProfiles  Attach per-vehicle randomized behavior params.
%   actors = applyBehaviorProfiles(actors, profiles)
%
% Each profile:
%   .id .vehicleClass .aggression [0-1] .headwayFactor .lateralDrift
%   .desiredSpeedMean .desiredSpeedStd
%
% Placeholder: stores parameters into actor's UserData struct.

if isempty(actors) || isempty(profiles); return; end

for i = 1:numel(actors)
    a = actors(i);
    if isfield(a.meta,'class')
        vClass = a.meta.class;
    else
        vClass = 'car';
    end
    pIdx = find(strcmpi({profiles.vehicleClass}, vClass), 1);
    if isempty(pIdx)
        pIdx = find(strcmp({profiles.vehicleClass}, 'car'),1);
    end
    if isempty(pIdx)
        continue;
    end
    p = profiles(pIdx);
    sMean = p.desiredSpeedMean + randn()*p.desiredSpeedStd;
    actors(i).meta.behavior = struct( ...
        'profileId', p.id, ...
        'vehicleClass', vClass, ...
        'aggression', p.aggression, ...
        'headwayFactor', p.headwayFactor, ...
        'lateralDrift', p.lateralDrift, ...
        'desiredSpeed', max(1, sMean));
end
end
