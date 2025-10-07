%% run_interactive_feature_demo - Full GUI Interactive Demo
% This script provides the complete interactive experience for feature placement.
% MUST be run in MATLAB GUI (not batch mode) for full functionality.
%
% Features:
%  - Click to select coordinates on map
%  - Choose from 8 different Indian micro-features  
%  - Real-time visualization updates
%  - Multiple feature placement sessions
%  - Complete save functionality
%
% Usage: Run this script in MATLAB GUI and follow prompts

function run_interactive_feature_demo()

clear; clc; close all;

% Check if GUI is available
if ~usejava('desktop') || ~feature('ShowFigureWindows')
    error(['This script requires MATLAB GUI with figure support.\n' ...
           'For batch mode, use: run_ind_digitaltwin_demo']);
end

fprintf('=== IND-DigitalTwin Full Interactive Feature Placement ===\n\n');

% Setup
currentDir = pwd;
if ~exist('setup_ind_digitaltwin_paths.m', 'file')
    error('Please run this script from the IND-DigitalTwin root directory');
end

setup_ind_digitaltwin_paths();

%% Load Base OSM Scenario
fprintf('🗺️  Loading OSM road network...\n');
osmFile = fullfile(currentDir, 'data', 'osm', 'sample_map.osm');
if ~isfile(osmFile)
    error('OSM file not found: %s', osmFile);
end

[baseScenario, osmMeta] = buildScenarioFromOSM(osmFile);
fprintf('✅ Loaded OSM map with %d roads\n', osmMeta.roadCreatedCount);

%% Display Base Road Network
fprintf('\n🎨 Displaying road network...\n');
baseFig = figure('Name', 'Interactive Feature Placement - Click to Add Features', ...
    'Position', [100 100 1400 900]);

plot(baseScenario);
axis equal; grid on;
xlabel('X (meters)', 'FontSize', 12);
ylabel('Y (meters)', 'FontSize', 12);
title({'Interactive Feature Placement', 'Select features from menu, then click on map'}, 'FontSize', 14);

% Set appropriate axis limits
if ~isempty(osmMeta.nodeXY)
    margin = 50;
    xlim([min(osmMeta.nodeXY(:,1))-margin, max(osmMeta.nodeXY(:,1))+margin]);
    ylim([min(osmMeta.nodeXY(:,2))-margin, max(osmMeta.nodeXY(:,2))+margin]);
end

%% Interactive Feature Placement
fprintf('✅ Road network displayed. Starting interactive session...\n');

% Available feature types
availableFeatures = {
    'pothole', 'Road surface damage/potholes';
    'barricadeCluster', 'Construction barriers and roadblocks';
    'parkedVehicleRow', 'Row of parked cars';
    'parkedRickshawRow', 'Auto-rickshaw parking area';
    'streetVendorStall', 'Street vendor setup';
    'temporaryMarket', 'Temporary market stalls';
    'peakHourEncroachment', 'Rush hour space usage';
    'cattleObstruction', 'Livestock on roadway'
};

allFeatures = [];
featureColors = lines(length(availableFeatures));
continueAdding = true;
sessionCount = 0;

fprintf('\n🎯 Interactive Feature Placement Started!\n');
fprintf('==========================================\n');

while continueAdding
    sessionCount = sessionCount + 1;
    fprintf('\n--- Session %d: Choose and Place Features ---\n', sessionCount);
    
    % Display feature menu
    fprintf('\n📋 Available Feature Types:\n');
    for i = 1:size(availableFeatures, 1)
        fprintf('  %d. %s - %s\n', i, availableFeatures{i,1}, availableFeatures{i,2});
    end
    
    % Get user choice
    while true
        choice = input(sprintf('\n🎯 Select feature type (1-%d): ', size(availableFeatures, 1)));
        if isnumeric(choice) && choice >= 1 && choice <= size(availableFeatures, 1)
            selectedFeature = availableFeatures{choice, 1};
            selectedDescription = availableFeatures{choice, 2};
            break;
        else
            fprintf('❌ Invalid choice. Please enter a number between 1 and %d.\n', size(availableFeatures, 1));
        end
    end
    
    fprintf('✅ Selected: %s (%s)\n', selectedFeature, selectedDescription);
    
    % Interactive coordinate selection
    fprintf('\n🖱️  INSTRUCTIONS:\n');
    fprintf('   1. Look at the map window\n');
    fprintf('   2. Click anywhere on the roads to place %s\n', selectedFeature);
    fprintf('   3. Click multiple times for multiple features\n');
    fprintf('   4. Press ENTER (without clicking) when finished\n\n');
    fprintf('⏳ Waiting for your clicks on the map...\n');
    
    coords = selectCoordinatesInteractively(baseScenario);
    
    if ~isempty(coords)
        % Place features
        feature = placeFeatureAtCoordinate(baseScenario, selectedFeature, coords(:,1), coords(:,2));
        
        % Add to collection
        feature.color = featureColors(choice, :);
        feature.description = selectedDescription;
        if isempty(allFeatures)
            allFeatures = feature;
        else
            allFeatures(end+1) = feature;
        end
        
        % Update display
        figure(baseFig);
        hold on;
        h = scatter(coords(:,1), coords(:,2), 180, featureColors(choice, :), 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 2);
        
        % Add labels
        for i = 1:size(coords, 1)
            text(coords(i,1)+15, coords(i,2)+15, sprintf('%s-%d', selectedFeature(1:3), i), ...
                'FontWeight', 'bold', 'Color', 'white', 'FontSize', 9, ...
                'BackgroundColor', featureColors(choice, :), 'EdgeColor', 'k');
        end
        
        % Update title
        totalFeatures = sum([allFeatures.count]);
        title({sprintf('Interactive Feature Placement - %d Features Placed', totalFeatures), ...
               'Continue placing or finish session'}, 'FontSize', 14);
        
        fprintf('✅ SUCCESS: Placed %d %s features!\n', size(coords, 1), selectedFeature);
        
        % Show running summary
        uniqueTypes = unique({allFeatures.type});
        fprintf('📊 Current session summary: %s\n', strjoin(uniqueTypes, ', '));
        
    else
        fprintf('⚠️  No coordinates selected for %s\n', selectedFeature);
    end
    
    % Continue?
    fprintf('\n❓ Add more features?\n');
    response = input('   Enter "y" for YES, anything else to FINISH: ', 's');
    continueAdding = strcmpi(response, 'y') || strcmpi(response, 'yes');
    
    if continueAdding
        fprintf('🔄 Starting new feature selection...\n');
    else
        fprintf('🏁 Finishing feature placement session...\n');
    end
end

%% Final Results and Saving
if ~isempty(allFeatures)
    createFinalVisualization(baseScenario, allFeatures, availableFeatures, featureColors, currentDir);
    saveResults(baseScenario, allFeatures, osmMeta, currentDir);
else
    fprintf('⚠️  No features were placed during this session.\n');
end

fprintf('\n🎉 Interactive Feature Placement Complete!\n');
fprintf('Thank you for using IND-DigitalTwin!\n');

end

function createFinalVisualization(baseScenario, allFeatures, availableFeatures, featureColors, currentDir)
    fprintf('\n🎨 Creating final enhanced visualization...\n');
    
    finalFig = figure('Name', 'Final Results - Interactive Feature Placement', ...
        'Position', [200 50 1400 900]);
    
    % Plot scenario
    plot(baseScenario);
    hold on;
    
    % Plot features with legend
    legendEntries = {'Roads'};
    legendHandles = get(gca, 'Children');
    if ~isempty(legendHandles)
        legendHandles = legendHandles(end); % Road handle
    end
    
    uniqueTypes = {};
    totalFeatures = 0;
    
    for i = 1:length(allFeatures)
        feature = allFeatures(i);
        coords = feature.featureCoords;
        
        h = scatter(coords(:,1), coords(:,2), 200, feature.color, 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 2);
        
        % Add to legend if new type
        if ~ismember(feature.type, uniqueTypes)
            legendHandles(end+1) = h;
            legendEntries{end+1} = sprintf('%s (%d)', feature.type, feature.count);
            uniqueTypes{end+1} = feature.type;
        end
        
        % Labels
        for j = 1:size(coords, 1)
            text(coords(j,1)+20, coords(j,2)+20, sprintf('%s-%d', feature.type(1:3), j), ...
                'FontWeight', 'bold', 'Color', 'white', 'FontSize', 10, ...
                'BackgroundColor', feature.color, 'EdgeColor', 'k');
        end
        
        totalFeatures = totalFeatures + feature.count;
    end
    
    % Enhance plot
    axis equal; grid on;
    xlabel('X (meters)', 'FontSize', 14);
    ylabel('Y (meters)', 'FontSize', 14);
    title(sprintf('Final Interactive Scenario: %d Features Across %d Types', ...
        totalFeatures, length(uniqueTypes)), 'FontSize', 16);
    
    if length(legendHandles) > 1
        legend(legendHandles, legendEntries, 'Location', 'best', 'FontSize', 11);
    end
    
    hold off;
    fprintf('✅ Final visualization created\n');
end

function saveResults(baseScenario, allFeatures, osmMeta, currentDir)
    fprintf('\n💾 Saving results...\n');
    
    % Create results structure
    results = struct();
    results.scenario = baseScenario;
    results.features = allFeatures;
    results.osmMeta = osmMeta;
    results.totalFeatures = sum([allFeatures.count]);
    results.uniqueTypes = unique({allFeatures.type});
    results.timestamp = datetime('now');
    results.mode = 'interactive_gui';
    
    % Create dist directory
    distDir = fullfile(currentDir, 'dist');
    if ~isfolder(distDir)
        mkdir(distDir);
    end
    
    % Save files
    matFile = fullfile(distDir, 'interactive_gui_scenario.mat');
    save(matFile, 'results', 'baseScenario', 'allFeatures', 'osmMeta');
    fprintf('✅ Scenario data: %s\n', matFile);
    
    figFile = fullfile(distDir, 'interactive_gui_plot.png');
    saveas(gcf, figFile);
    fprintf('✅ Plot image: %s\n', figFile);
    
    % Detailed report
    reportFile = fullfile(distDir, 'interactive_gui_report.txt');
    fid = fopen(reportFile, 'w');
    fprintf(fid, 'IND-DigitalTwin Interactive GUI Feature Placement Report\n');
    fprintf(fid, '====================================================\n\n');
    fprintf(fid, 'Session Date: %s\n', char(results.timestamp));
    fprintf(fid, 'Mode: Interactive GUI\n');
    fprintf(fid, 'Total Features: %d\n', results.totalFeatures);
    fprintf(fid, 'Feature Types: %s\n\n', strjoin(results.uniqueTypes, ', '));
    
    fprintf(fid, 'Detailed Feature Placement:\n');
    fprintf(fid, '---------------------------\n');
    for i = 1:length(allFeatures)
        fprintf(fid, '\n%d. %s (%d instances):\n', i, allFeatures(i).type, allFeatures(i).count);
        coords = allFeatures(i).featureCoords;
        for j = 1:size(coords, 1)
            fprintf(fid, '   Point %d: (%.2f, %.2f)\n', j, coords(j,1), coords(j,2));
        end
    end
    fclose(fid);
    fprintf('✅ Detailed report: %s\n', reportFile);
    
    % Workspace
    assignin('base', 'interactiveResults', results);
    fprintf('✅ Workspace variable: interactiveResults\n');
    
    fprintf('\n📁 All files saved to: %s\n', distDir);
end