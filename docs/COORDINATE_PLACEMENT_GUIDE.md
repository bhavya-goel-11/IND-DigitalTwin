# Adding Features at Specific Coordinates

This guide explains how to place Indian micro-features (potholes, barricades, etc.) at exact coordinates of your choice in OSM-based scenarios.

## Current Placement System

The toolkit currently uses **heuristic placement rules** that automatically position features relative to road geometry:

- `nearStopLine`: Random positions near junction center (within 12m radius)
- `approachNorth/South/East/West`: Along approach directions to intersections  
- `shoulderEast/West/North/South`: Lateral offset from approach lines
- `random`: Random valid positions on road network

## Method 1: Add Exact Coordinate Placement (Recommended)

### Step 1: Create Enhanced Configuration
Add features with exact coordinates in your config file:

```json
{
  "microFeatures": [
    {
      "type": "pothole",
      "placementRule": "exactCoordinates", 
      "coordinates": [
        {"x": 25.5, "y": 10.2, "z": 0.0},
        {"x": 30.1, "y": 15.7, "z": 0.0}
      ]
    },
    {
      "type": "barricadeCluster",
      "placementRule": "exactCoordinates",
      "coordinates": [
        {"x": 40.0, "y": 20.0, "z": 0.0}
      ]
    }
  ]
}
```

### Step 2: Enhance augmentScenario.m
Add support for exact coordinate placement:

```matlab
% In augmentScenario.m, add this case to the switch statement:
case 'exactcoordinates'
    if isfield(f, 'coordinates') && ~isempty(f.coordinates)
        coords = f.coordinates;
        count = length(coords);
        pos = zeros(count, 3);
        for i = 1:count
            pos(i, :) = [coords(i).x, coords(i).y, coords(i).z];
        end
    else
        error('exactCoordinates placement rule requires coordinates field');
    end
```

## Method 2: Direct MATLAB Coordinate Placement

### Quick Manual Placement Script
Create a helper script to place features at exact coordinates:

```matlab
function out = addFeatureAtCoordinate(scenario, featureType, x, y, z)
% Add a single feature at exact coordinates
% Usage: out = addFeatureAtCoordinate(scenario, 'pothole', 25.5, 10.2, 0.0)

if nargin < 5
    z = 0.0;  % Default ground level
end

% Create feature structure
feature = struct();
feature.type = featureType;
feature.rule = 'manual';
feature.count = 1;
feature.positions = [x, y, z];

% Apply to scenario (you can extend this to actually modify the scenario)
out.scenario = scenario;
out.appliedFeatures = feature;
out.notes = {sprintf('Manually placed %s at (%.1f, %.1f, %.1f)', featureType, x, y, z)};

fprintf('Feature %s placed at coordinates: (%.2f, %.2f, %.2f)\n', featureType, x, y, z);
end
```

## Method 3: Interactive Coordinate Selection

### Visual Coordinate Picker
```matlab
function coordinates = pickCoordinatesFromPlot(scenario)
% Interactive coordinate selection from scenario plot
% Usage: coords = pickCoordinatesFromPlot(scenario)

% Plot the scenario
figure;
plot(scenario);
title('Click on the plot to select feature coordinates. Press Enter when done.');
grid on;
axis equal;

% Collect coordinates interactively
coordinates = [];
hold on;

while true
    [x, y] = ginput(1);  % Get one point from user click
    if isempty(x)
        break;  % User pressed Enter
    end
    
    % Mark the selected point
    plot(x, y, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
    coordinates(end+1,:) = [x, y, 0.0]; %#ok<AGROW>
    
    fprintf('Selected coordinate: (%.2f, %.2f)\n', x, y);
end

hold off;
fprintf('Total coordinates selected: %d\n', size(coordinates, 1));
end
```

## Complete Workflow Example

### Step 1: Generate Base Scenario
```matlab
% Load your OSM-based scenario
addpath('src/matlab');
out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');
baseScenario = out.scenario;

% Plot to see the road network
figure(1);
plot(baseScenario);
title('Road Network - Note coordinates for feature placement');
grid on;
axis equal;
```

### Step 2: Choose Coordinates
```matlab
% Method A: Visual selection
coordinates = pickCoordinatesFromPlot(baseScenario);

% Method B: Manual specification  
coordinates = [
    25.5, 10.2, 0.0;    % Pothole location 1
    30.1, 15.7, 0.0;    % Pothole location 2  
    40.0, 20.0, 0.0     % Barricade location
];
```

### Step 3: Place Features
```matlab
% Create custom feature configuration
customConfig = struct();
customConfig.microFeatures = [];

% Add potholes at first two coordinates
customConfig.microFeatures(1).type = 'pothole';
customConfig.microFeatures(1).placementRule = 'exactCoordinates';
customConfig.microFeatures(1).coordinates = [];
for i = 1:2
    customConfig.microFeatures(1).coordinates(i).x = coordinates(i,1);
    customConfig.microFeatures(1).coordinates(i).y = coordinates(i,2);
    customConfig.microFeatures(1).coordinates(i).z = coordinates(i,3);
end

% Add barricade at third coordinate
customConfig.microFeatures(2).type = 'barricadeCluster';
customConfig.microFeatures(2).placementRule = 'exactCoordinates';
customConfig.microFeatures(2).coordinates(1).x = coordinates(3,1);
customConfig.microFeatures(2).coordinates(1).y = coordinates(3,2);
customConfig.microFeatures(2).coordinates(1).z = coordinates(3,3);

% Apply features (requires enhanced augmentScenario.m)
enhancedOut = augmentScenario(baseScenario, customConfig, out.osmMeta);
```

### Step 4: Visualize Results  
```matlab
% Plot scenario with exact feature placement
figure(2);
plot(enhancedOut.scenario);
hold on;

% Overlay feature positions
for i = 1:length(enhancedOut.appliedFeatures)
    feature = enhancedOut.appliedFeatures(i);
    pos = feature.positions;
    
    % Color-code by feature type
    switch feature.type
        case 'pothole'
            scatter(pos(:,1), pos(:,2), 100, 'r', 'filled', 'MarkerEdgeColor', 'k');
        case 'barricadeCluster'
            scatter(pos(:,1), pos(:,2), 150, 'b', 's', 'filled', 'MarkerEdgeColor', 'k');
        otherwise
            scatter(pos(:,1), pos(:,2), 120, 'g', '^', 'filled', 'MarkerEdgeColor', 'k');
    end
end

legend('Roads', 'Potholes', 'Barricades', 'Location', 'best');
title('Road Network with Features at Exact Coordinates');
grid on;
axis equal;
hold off;
```

## Understanding Coordinate Systems

### OSM to Local Coordinates
The toolkit converts OSM lat/lon to local XY coordinates. To find the coordinate system:

```matlab
% Check coordinate bounds of your scenario
out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');

% Print coordinate ranges
if isfield(out, 'osmMeta') && isfield(out.osmMeta, 'coordinateBounds')
    bounds = out.osmMeta.coordinateBounds;
    fprintf('X range: %.2f to %.2f meters\n', bounds.xMin, bounds.xMax);
    fprintf('Y range: %.2f to %.2f meters\n', bounds.yMin, bounds.yMax);
else
    % Extract from road centers
    roadSegs = out.scenario.RoadSegments;
    allX = []; allY = [];
    for r = 1:numel(roadSegs)
        centers = roadSegs(r).RoadCenters;
        allX = [allX; centers(:,1)];
        allY = [allY; centers(:,2)];
    end
    fprintf('X range: %.2f to %.2f meters\n', min(allX), max(allX));
    fprintf('Y range: %.2f to %.2f meters\n', min(allY), max(allY));
end
```

## Available Feature Types

Current feature types defined in [`src/assets/metadata/`](../src/assets/metadata/):
- `pothole` - Road surface depressions
- `barricadeCluster` - Construction barriers  
- `parkedVehicleRow` - Parked cars
- `parkedRickshawRow` - Auto-rickshaw parking
- `streetVendorStall` - Vendor setups
- `temporaryMarket` - Market stalls
- `peakHourEncroachment` - Rush hour obstacles
- `cattleObstruction` - Livestock obstructions

## Tips for Accurate Placement

1. **Plot first**: Always visualize the road network before placing features
2. **Stay on roads**: Place coordinates near actual road centerlines for realism
3. **Check bounds**: Ensure coordinates are within the OSM area bounds
4. **Test incrementally**: Place one feature at a time to verify positioning
5. **Use Z=0**: Keep Z coordinate at 0.0 for ground-level features

This system gives you complete control over feature placement while maintaining compatibility with the existing asset library and visualization tools.