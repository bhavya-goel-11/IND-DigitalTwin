%% Demo: Adding Features at Specific Coordinates
% This script demonstrates how to add potholes and other features
% at exact coordinates of your choice in an OSM-based scenario.

clear; clc; close all;

%% Step 1: Setup Paths and Load Base Scenario
fprintf('=== Setting up paths and loading OSM-based scenario ===\n');
setup_ind_digitaltwin_paths();
out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');
baseScenario = out.scenario;

% Display coordinate bounds
roadSegs = baseScenario.RoadSegments;
allX = []; allY = [];
for r = 1:numel(roadSegs)
    centers = roadSegs(r).RoadCenters;
    allX = [allX; centers(:,1)];
    allY = [allY; centers(:,2)];
end
fprintf('Scenario coordinate bounds:\n');
fprintf('  X: %.2f to %.2f meters\n', min(allX), max(allX));
fprintf('  Y: %.2f to %.2f meters\n', min(allY), max(allY));

%% Step 2: Visualize Road Network
fprintf('\n=== Plotting road network ===\n');
figure(1);
plot(baseScenario);
title('Original Road Network');
grid on; axis equal;
xlabel('X (meters)'); ylabel('Y (meters)');

%% Step 3: Method A - Manual Coordinate Specification
fprintf('\n=== Method A: Manual coordinate specification ===\n');

% Define exact coordinates for features
potholeCoords = [
    mean(allX)-5, mean(allY)+3, 0;    % Near center, slightly offset
    min(allX)+8,  mean(allY)-2, 0;    % Left side of network
    max(allX)-8,  mean(allY)+1, 0     % Right side of network
];

barricadeCoords = [
    mean(allX)+3, mean(allY)-4, 0     % Center-south area
];

fprintf('Placing potholes at:\n');
for i = 1:size(potholeCoords, 1)
    fprintf('  (%.2f, %.2f, %.2f)\n', potholeCoords(i,:));
end

fprintf('Placing barricade at:\n');
fprintf('  (%.2f, %.2f, %.2f)\n', barricadeCoords);

%% Step 4: Apply Features Using Helper Function
fprintf('\n=== Applying features ===\n');

% Place potholes
potholeFeature = placeFeatureAtCoordinate(baseScenario, 'pothole', ...
    potholeCoords(:,1), potholeCoords(:,2));

% Place barricade
barricadeFeature = placeFeatureAtCoordinate(baseScenario, 'barricadeCluster', ...
    barricadeCoords(:,1), barricadeCoords(:,2));

%% Step 5: Visualize Results
fprintf('\n=== Visualizing results ===\n');
figure(2);
plot(baseScenario);
hold on;

% Plot potholes
scatter(potholeFeature.featureCoords(:,1), potholeFeature.featureCoords(:,2), ...
    120, 'r', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2);

% Plot barricades  
scatter(barricadeFeature.featureCoords(:,1), barricadeFeature.featureCoords(:,2), ...
    180, 'b', 's', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2);

% Add labels
for i = 1:size(potholeFeature.featureCoords, 1)
    text(potholeFeature.featureCoords(i,1)+1, potholeFeature.featureCoords(i,2)+1, ...
        sprintf('P%d', i), 'FontWeight', 'bold', 'Color', 'red');
end

for i = 1:size(barricadeFeature.featureCoords, 1)
    text(barricadeFeature.featureCoords(i,1)+1, barricadeFeature.featureCoords(i,2)+1, ...
        sprintf('B%d', i), 'FontWeight', 'bold', 'Color', 'blue');
end

legend('Roads', 'Potholes', 'Barricades', 'Location', 'best');
title('Road Network with Features at Exact Coordinates');
grid on; axis equal;
xlabel('X (meters)'); ylabel('Y (meters)');
hold off;

%% Step 6 (Optional): Interactive Coordinate Selection
fprintf('\n=== Step 6: Interactive coordinate selection ===\n');
fprintf('Uncomment the following lines to try interactive selection:\n');
fprintf('%% coords = selectCoordinatesInteractively(baseScenario);\n');
fprintf('%% newFeature = placeFeatureAtCoordinate(baseScenario, ''pothole'', coords(:,1), coords(:,2));\n');

% Uncomment these lines to try interactive selection:
% coords = selectCoordinatesInteractively(baseScenario);
% if ~isempty(coords)
%     newFeature = placeFeatureAtCoordinate(baseScenario, 'pothole', coords(:,1), coords(:,2));
%     fprintf('Interactive features placed successfully!\n');
% end

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('✓ Loaded OSM-based scenario\n');
fprintf('✓ Placed %d potholes at exact coordinates\n', size(potholeCoords, 1));
fprintf('✓ Placed %d barricade cluster at exact coordinates\n', size(barricadeCoords, 1));
fprintf('✓ Visualized results with color-coded features\n');
fprintf('\nNext steps:\n');
fprintf('1. Modify coordinates in this script for your specific needs\n');
fprintf('2. Try different feature types (see available types below)\n');
fprintf('3. Use selectCoordinatesInteractively() for visual selection\n');

%% Available Feature Types
fprintf('\n=== Available Feature Types ===\n');
featureTypes = {'pothole', 'barricadeCluster', 'parkedVehicleRow', ...
    'parkedRickshawRow', 'streetVendorStall', 'temporaryMarket', ...
    'peakHourEncroachment', 'cattleObstruction'};

for i = 1:length(featureTypes)
    fprintf('  • %s\n', featureTypes{i});
end

fprintf('\nDemo complete! Check figures 1 and 2 for visualization.\n');