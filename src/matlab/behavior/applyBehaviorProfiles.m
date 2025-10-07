function actors = applyBehaviorProfiles(actors, profiles)
% applyBehaviorProfiles  Attach per-vehicle randomized behavior params.
%   actors = applyBehaviorProfiles(actors, profiles)
%
% Each profile (optional fields have defaults):
%   Required: .id .vehicleClass
%   Optional (defaults):
%     .aggression (0.5)
%     .headwayFactor (1.0)
%     .lateralDrift (0)  % conceptual placeholder
%     .desiredSpeedMean (14)  % ~50 km/h
%     .desiredSpeedStd (2)
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
    % Apply defaults for missing fields
    if ~isfield(p,'aggression');       p.aggression = 0.5; end
    if ~isfield(p,'headwayFactor');    p.headwayFactor = 1.0; end
    if ~isfield(p,'lateralDrift');     p.lateralDrift = 0; end
    if ~isfield(p,'desiredSpeedMean'); p.desiredSpeedMean = 14; end
    if ~isfield(p,'desiredSpeedStd');  p.desiredSpeedStd = 2; end
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
