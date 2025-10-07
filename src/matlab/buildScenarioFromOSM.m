function [scenario, osmMeta] = buildScenarioFromOSM(osmPath)
% buildScenarioFromOSM  Minimal OSM -> drivingScenario importer (hackathon scope).
%   scenario = buildScenarioFromOSM('data/osm/sample_map.osm')
%
% Features implemented (lightweight):
%   - XML parse of <node> (id, lat, lon) and <way> with highway tag
%   - Simple local tangent plane projection (equirectangular) relative to first node
%   - Creation of roads via road(scenario, centerline, width) with default 2-lane spec
%   - Stores metadata: original lat/lon arrays, mapping function handles, OSM stats
% Limitations:
%   - Ignores turn restrictions, lane counts, oneway (except placeholder storage)
%   - No elevation, curvature smoothing beyond vertex sequence
%   - No junction geometry synthesis
%   - Assumes small geographic extent (OK for local junctions) for equirectangular projection
%
% Enhancements possible later: proper ellipsoidal projection, lane specs, speed limits,
% intersection synthesis, classification of approaches, conflict zone extraction.

if ~isfile(osmPath)
    error('OSM file not found: %s', osmPath);
end

txt = fileread(osmPath);

% Extract nodes (robust parsing to handle attributes in any order)
% First get all node elements (self-closing and with content)
nodeElements = regexp(txt, '<node[^>]*/?>', 'match');

nodeTokens = {};
for ne = 1:numel(nodeElements)
    element = nodeElements{ne};
    % Extract id, lat, lon from each node element
    idMatch = regexp(element, 'id="(\d+)"', 'tokens', 'once');
    latMatch = regexp(element, 'lat="([0-9\.-]+)"', 'tokens', 'once');
    lonMatch = regexp(element, 'lon="([0-9\.-]+)"', 'tokens', 'once');
    
    if ~isempty(idMatch) && ~isempty(latMatch) && ~isempty(lonMatch)
        nodeTokens{end+1} = {idMatch{1}, latMatch{1}, lonMatch{1}}; %#ok<AGROW>
    end
end
nodeCount = numel(nodeTokens);
nodeIds = zeros(nodeCount,1,'uint64');
nodeLat = zeros(nodeCount,1);
nodeLon = zeros(nodeCount,1);
for i=1:nodeCount
    nodeIds(i) = uint64(str2double(nodeTokens{i}{1}));
    nodeLat(i) = str2double(nodeTokens{i}{2});
    nodeLon(i) = str2double(nodeTokens{i}{3});
end

if nodeCount==0
    error('No nodes parsed from OSM file: %s', osmPath);
end

% Build map id->index
idMap = containers.Map(nodeIds, 1:nodeCount);

% Extract ways with highway tag (rough slice)
wayBlocks = regexp(txt, '<way[^>]*>.*?</way>', 'match');
highwayWays = struct('id',{},'nodeRefs',{},'tags',{});
for w = 1:numel(wayBlocks)
    blk = wayBlocks{w};
    if contains(blk, '<tag k="highway"')
        % Way id
        idTok = regexp(blk,'<way[^>]*id="(\d+)"','tokens','once');
        if isempty(idTok); continue; end
        wid = uint64(str2double(idTok{1}));
        % Node refs
        ndTok = regexp(blk,'<nd ref="(\d+)"','tokens');
        refs = uint64(cellfun(@(c) str2double(c{1}), ndTok));
        % Tags (basic)
        tagTok = regexp(blk,'<tag k="([^"]+)" v="([^"]+)"','tokens');
        tags = containers.Map();
        for t=1:numel(tagTok)
            tags(tagTok{t}{1}) = tagTok{t}{2};
        end
        % Filter out non-roadway highway tags
        if isKey(tags, 'highway')
            hwType = tags('highway');
            nonRoadTypes = {'bus_stop', 'street_lamp', 'motorway_junction', 'mini_roundabout'};
            if ~any(strcmp(hwType, nonRoadTypes))
                highwayWays(end+1) = struct('id',wid,'nodeRefs',refs,'tags',tags); %#ok<AGROW>
            end
        end
    end
end

% Projection (local tangent) using first node as origin
lat0 = nodeLat(1)*pi/180; lon0 = nodeLon(1)*pi/180;
R = 6371000; % meters
cosLat0 = cos(lat0);
toXY = @(lat,lon) [(lon*pi/180 - lon0)*R*cosLat0, (lat*pi/180 - lat0)*R];

nodeXY = zeros(nodeCount,2);
for i=1:nodeCount
    nodeXY(i,:) = toXY(nodeLat(i), nodeLon(i));
end

scenario = drivingScenario('StopTime',300);

roadCount = 0;
storedWays = struct('id',{},'centers',{},'hwType',{});
for k=1:numel(highwayWays)
    refs = highwayWays(k).nodeRefs;
    if isempty(refs); continue; end
    % Convert refs to cell array for Map queries
    refCells = num2cell(refs);
    % Filter refs that exist
    existsMask = cellfun(@(r) isKey(idMap, r), refCells);
    if ~any(existsMask); continue; end
    refs = refs(existsMask);
    if numel(refs) < 2
        continue; % need at least a segment
    end
    idxCells = values(idMap, num2cell(refs));
    idxs = cell2mat(idxCells);
    centers = nodeXY(idxs,:);
    % Minimal thinning - only remove truly duplicate points
    d = [0; sqrt(sum(diff(centers).^2,2))];
    keepMask = [true; d(2:end) > 0.001]; % 1mm threshold - very minimal
    centers = centers(keepMask,:);
    if size(centers,1) < 2
        continue;
    end
    
    % Determine lane specification based on highway type
    hwType = 'residential'; % default
    if isKey(highwayWays(k).tags, 'highway')
        hwType = highwayWays(k).tags('highway');
    end
    
    % Lane count and width based on highway classification
    switch lower(hwType)
        case {'trunk', 'primary'}
            laneSpec = lanespec(3, 'Width', 4.0); % 3 lanes, 4m width
        case {'primary_link', 'secondary'}
            laneSpec = lanespec(2, 'Width', 3.5); % 2 lanes, 3.5m width
        case {'tertiary', 'tertiary_link'}
            laneSpec = lanespec(2, 'Width', 3.0); % 2 lanes, 3m width
        case {'residential', 'unclassified'}
            laneSpec = lanespec(1, 'Width', 2.8); % 1 lane, 2.8m width
        case {'service', 'living_street'}
            laneSpec = lanespec(1, 'Width', 2.5); % 1 lane, 2.5m width
        otherwise
            laneSpec = lanespec(2, 'Width', 3.0); % default
    end
    
    try
        road(scenario, centers, 'Lanes', laneSpec); %#ok<*NASGU>
        roadCount = roadCount + 1;
        storedWays(end+1) = struct('id',double(highwayWays(k).id),'centers',centers,'hwType',hwType); %#ok<AGROW>
    catch ME
        warning('Skipping way %d (%s) due to road creation error: %s', highwayWays(k).id, hwType, ME.message);
    end
end

% Metadata (return value)
osmMeta = struct();
osmMeta.osmSource = osmPath;
osmMeta.nodeIds = nodeIds;
osmMeta.nodeLat = nodeLat;
osmMeta.nodeLon = nodeLon;
osmMeta.nodeXY = nodeXY;
osmMeta.highwayWayCount = numel(highwayWays);
osmMeta.roadCreatedCount = roadCount;
osmMeta.ways = storedWays;
osmMeta.originLatLon = [nodeLat(1) nodeLon(1)];
osmMeta.projection.type = 'equirectangular-local';
osmMeta.projection.lat0 = nodeLat(1);
osmMeta.projection.lon0 = nodeLon(1);
osmMeta.projection.radius = R;
osmMeta.note = 'Lightweight OSM import (hackathon scope)';

% Debug info
hwTypes = {storedWays.hwType};
[uniqueTypes, ~, idx] = unique(hwTypes);
typeCounts = accumarray(idx, 1);

% Filter out empty highway types to avoid containers.Map error
validIdx = ~cellfun(@isempty, uniqueTypes);
validTypes = uniqueTypes(validIdx);
validCounts = typeCounts(validIdx);

if ~isempty(validTypes)
    osmMeta.highwayTypeCounts = containers.Map(validTypes, num2cell(validCounts));
else
    osmMeta.highwayTypeCounts = containers.Map();
end

fprintf('[OSM] Parsed %d nodes, %d highway ways, created %d roads\n', nodeCount, numel(highwayWays), roadCount);
for i = 1:length(validTypes)
    fprintf('[OSM] %s: %d roads\n', validTypes{i}, validCounts(i));
end

end
