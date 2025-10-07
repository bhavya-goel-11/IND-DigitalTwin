function out = augmentScenario(baseScenario, config, osmMeta)
% augmentScenario  Apply Indian urban micro-features & behavior overlays.
%   Iteration 2: geometry-aware heuristic placement.
%   Steps:
%     1. Estimate junction center (mean of midpoints of road segments)
%     2. Build approach descriptors (endpoint -> center vectors)
%     3. Place features according to placementRule patterns
%        - nearStopLine: random points near center
%        - approach<Dir>: along inbound direction (Dir in {North,South,East,West})
%        - shoulder<Dir>: lateral offset from approach line
%   (Future: integrate with lane speed & width adjustments)

out.scenario = baseScenario;
out.appliedFeatures = struct([]);
out.notes = {};

if ~isfield(config,'microFeatures') || isempty(config.microFeatures)
    out.notes{end+1} = 'No micro-features specified.'; %#ok<AGROW>
    return;
end

% Prepare road snapping data if osmMeta provided
snapEnabled = (nargin >=3) && ~isempty(osmMeta) && isfield(osmMeta,'ways') && ~isempty(osmMeta.ways);
allWayPts = [];
if snapEnabled
    for w = 1:numel(osmMeta.ways)
        c2 = osmMeta.ways(w).centers;
        if size(c2,2)==2
            c2 = [c2 zeros(size(c2,1),1)];
        end
        allWayPts = [allWayPts; c2]; %#ok<AGROW>
    end
end

% Collect road information
try
    roadSegs = baseScenario.RoadSegments; %#ok<PROPLC>
catch
    roadSegs = [];
end

midpoints = [];
allCenters = [];
for r = 1:numel(roadSegs)
    c = roadSegs(r).RoadCenters; %#ok<PROP>
    allCenters = [allCenters; c]; %#ok<AGROW>
    midpoints(end+1,:) = c(round(size(c,1)/2),:); %#ok<AGROW>
end

if isempty(midpoints)
    jCenter = [0 0 0];
    out.notes{end+1} = 'Heuristic center fallback to origin.'; %#ok<AGROW>
else
    jCenter = mean(midpoints,1);
end

% Build approaches (choose far endpoint as tail, near endpoint as head)
approaches = struct('tail', {}, 'head', {}, 'dir', {}, 'bearing', {});
for r = 1:numel(roadSegs)
    c = roadSegs(r).RoadCenters; %#ok<PROP>
    if size(c,1) < 2, continue; end
    d1 = norm(c(1,1:2)-jCenter(1,1:2));
    d2 = norm(c(end,1:2)-jCenter(1,1:2));
    if d1 > d2
        tail = c(1,1:3); head = c(end,1:3);
    else
        tail = c(end,1:3); head = c(1,1:3);
    end
    vec = head(1,1:2)-tail(1,1:2);
    if norm(vec) < 1e-3, continue; end
    dirUnit = vec/norm(vec);
    bearing = atan2d(dirUnit(2),dirUnit(1));
    approaches(end+1) = struct('tail',tail,'head',head,'dir',dirUnit,'bearing',bearing); %#ok<AGROW>
end

% Direction classifier
compassFromBearing = @(b) classifyBearing(b);

for k = 1:numel(config.microFeatures)
    f = config.microFeatures(k);
    if isfield(f,'placementRule')
        rule = f.placementRule;
    else
        rule = 'unspecified';
    end
    if isfield(f,'count')
        count = f.count;
    else
        count = 1;
    end
    pos = zeros(count,3);
    switch lower(rule)
        case 'nearstopline'
            radius = 12; % meters
            for i=1:count
                ang = rand()*2*pi; rr = radius*sqrt(rand());
                pos(i,:) = jCenter + [rr*cos(ang) rr*sin(ang) 0];
            end
        otherwise
            tokens = regexp(rule,'^(approach|shoulder)(north|south|east|west)$','tokens','once');
            if ~isempty(tokens)
                kind = tokens{1}; dirName = tokens{2};
                cand = [];
                for a = 1:numel(approaches)
                    if strcmpi(compassFromBearing(approaches(a).bearing),dirName)
                        cand(end+1) = a; %#ok<AGROW>
                    end
                end
                if isempty(cand)
                    pos = repmat(jCenter,count,1);
                else
                    for i=1:count
                        aidx = cand(randi(numel(cand)));
                        ap = approaches(aidx);
                        t = 0.5 + 0.4*rand(); % toward center
                        base = ap.tail + (ap.head - ap.tail)*t;
                        lateral = [-ap.dir(2) ap.dir(1)];
                        if strcmpi(kind,'shoulder')
                            offset = (1.5 + 0.5*rand())*lateral; % shoulder offset
                        else
                            offset = (randn()*0.5)*lateral; % minor jitter
                        end
                        pos(i,:) = [base(1:2)+offset 0];
                    end
                end
            else
                % Fallback random picking of road center points
                if isempty(allCenters)
                    pos = repmat(jCenter,count,1);
                else
                    idx = randi(size(allCenters,1),count,1);
                    pos = allCenters(idx,1:3);
                end
            end
    end
    % Optional snapping to nearest road centerline points (XY)
    if snapEnabled && ~isempty(pos)
        for si=1:size(pos,1)
            diffs = allWayPts(:,1:2) - pos(si,1:2);
            [~,mi] = min(sum(diffs.^2,2));
            % Blend slightly toward road center to preserve some randomness
            snapped = allWayPts(mi,1:2);
            pos(si,1:2) = 0.7*snapped + 0.3*pos(si,1:2);
        end
    end
    placed = struct('type',f.type,'rule',rule,'count',count,'positions',pos);
    if isempty(out.appliedFeatures)
        out.appliedFeatures = placed;
    else
        out.appliedFeatures(end+1) = placed; %#ok<AGROW>
    end
end

out.notes{end+1} = sprintf('Placed %d feature groups (heuristic).', numel(out.appliedFeatures)); %#ok<AGROW>
end

function dirName = classifyBearing(b)
% Map bearing degrees to one of four cardinal directions.
if b >= -45 && b < 45
    dirName = 'east';
elseif b >= 45 && b < 135
    dirName = 'north';
elseif b >= -135 && b < -45
    dirName = 'south';
else
    dirName = 'west';
end
end
