function metrics = collectMetrics(outStruct)
% collectMetrics  Basic metrics from generated scenario struct.
%   metrics = collectMetrics(out)
% Provides:
%   - featureCounts (by type)
%   - vehicleClassCounts
%   - totalVehicles
%   (Future) average speeds, queue length proxies

metrics = struct();

% Feature counts
featCounts = struct();
if isfield(outStruct,'features') && ~isempty(outStruct.features)
    for i=1:numel(outStruct.features)
        t = outStruct.features(i).type;
        if ~isfield(featCounts,t); featCounts.(t) = 0; end
        featCounts.(t) = featCounts.(t) + outStruct.features(i).count;
    end
end
metrics.featureCounts = featCounts;

% Vehicle class counts
vehCounts = struct();
if isfield(outStruct,'spawnedActors')
    acts = outStruct.spawnedActors;
    for i=1:numel(acts)
        if isfield(acts(i).meta,'class')
            cls = acts(i).meta.class;
        else
            cls = 'unknown';
        end
        if ~isfield(vehCounts,cls); vehCounts.(cls)=0; end
        vehCounts.(cls) = vehCounts.(cls)+1;
    end
end
metrics.vehicleClassCounts = vehCounts;
metrics.totalVehicles = sum(struct2arraySafe(vehCounts));

end

function s = struct2arraySafe(st)
if isempty(fieldnames(st))
    s = 0; return
end
f = fieldnames(st); v = zeros(1,numel(f));
for i=1:numel(f); v(i) = st.(f{i}); end
s = sum(v);
end
