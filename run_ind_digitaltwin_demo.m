%% run_ind_digitaltwin_demo - Interactive Feature Placement Demo
% Interactive demo for IND-DigitalTwin with user-driven feature placement.
% 
% USAGE:
%   - For INTERACTIVE mode: Run in MATLAB GUI (supports user input)
%   - For BATCH mode: Runs automatic demo with predefined features
%
% This demo will:
%  1. Load OSM road network and display the map
%  2. Place features (interactive in GUI, automatic in batch)
%  3. Show final scenario with features
%  4. Save results to dist/ directory

clear; clc; close all;
fprintf('=== IND-DigitalTwin Interactive Feature Placement Demo ===\n\n');

% Setup
repoRoot = fileparts(mfilename('fullpath'));
cd(repoRoot);
setup_ind_digitaltwin_paths();

%% Load Base OSM Scenario (without predefined features)
fprintf('🗺️  Loading OSM road network...\n');
osmFile = fullfile(repoRoot, 'data', 'osm', 'sample_map.osm');
if ~isfile(osmFile)
    error('OSM file not found: %s', osmFile);
end

% Build clean scenario without predefined features
[baseScenario, osmMeta] = buildScenarioFromOSM(osmFile);
fprintf('✅ Loaded OSM map with %d roads\n', osmMeta.roadCreatedCount);
fprintf('📍 Coordinate bounds: X[%.1f, %.1f], Y[%.1f, %.1f]\n', ...
    min(osmMeta.nodeXY(:,1)), max(osmMeta.nodeXY(:,1)), ...
    min(osmMeta.nodeXY(:,2)), max(osmMeta.nodeXY(:,2)));

%% Display Base Road Network
fprintf('\n🎨 Displaying road network...\n');
baseFig = figure('Name', 'OSM Road Network - Ready for Feature Placement', ...
    'Position', [100 100 1200 800]);

% Plot road network
plot(baseScenario);
axis equal; grid on;
xlabel('X (meters)', 'FontSize', 12);
ylabel('Y (meters)', 'FontSize', 12);
title({'OSM Road Network', 'Ready for Interactive Feature Placement'}, 'FontSize', 14);

% Set appropriate axis limits
if ~isempty(osmMeta.nodeXY)
    margin = 50; % 50m margin
    xlim([min(osmMeta.nodeXY(:,1))-margin, max(osmMeta.nodeXY(:,1))+margin]);
    ylim([min(osmMeta.nodeXY(:,2))-margin, max(osmMeta.nodeXY(:,2))+margin]);
end

fprintf('✅ Road network displayed. Ready for interactive feature placement!\n');

%% Feature Placement - Interactive or Automatic
fprintf('\n🎯 Starting Feature Placement\n');
fprintf('==============================\n');

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

% Check if running in batch mode (no GUI input support)
isInteractiveMode = usejava('desktop') && feature('ShowFigureWindows');

if isInteractiveMode
    fprintf('🖱️  INTERACTIVE MODE: You can select coordinates by clicking\n');
    fprintf('📋 Available Feature Types:\n');
    for i = 1:size(availableFeatures, 1)
        fprintf('  %d. %s - %s\n', i, availableFeatures{i,1}, availableFeatures{i,2});
    end
    
    % Interactive mode - requires GUI
    continueAdding = true;
    sessionCount = 0;
    
    while continueAdding
        sessionCount = sessionCount + 1;
        fprintf('\n--- Feature Placement Session %d ---\n', sessionCount);
        
        % Get user choice for feature type
        while true
            try
                choice = input(sprintf('\nSelect feature type (1-%d): ', size(availableFeatures, 1)));
                if isnumeric(choice) && choice >= 1 && choice <= size(availableFeatures, 1)
                    selectedFeature = availableFeatures{choice, 1};
                    selectedDescription = availableFeatures{choice, 2};
                    break;
                else
                    fprintf('❌ Invalid choice. Please enter a number between 1 and %d.\n', size(availableFeatures, 1));
                end
            catch
                % Fallback if input fails
                fprintf('⚠️  Input failed. Using default: pothole\n');
                choice = 1;
                selectedFeature = availableFeatures{1, 1};
                selectedDescription = availableFeatures{1, 2};
                break;
            end
        end
        
        fprintf('✅ Selected: %s (%s)\n', selectedFeature, selectedDescription);
        
        % Interactive coordinate selection
        fprintf('\n🖱️  Click on the map to place %s features...\n', selectedFeature);
        fprintf('   Instructions: Click anywhere on roads, then press ENTER\n');
        
        try
            coords = selectCoordinatesInteractively(baseScenario);
        catch ME
            fprintf('⚠️  Interactive selection failed: %s\n', ME.message);
            fprintf('   Using automatic placement instead...\n');
            coords = [];
        end
        
        if ~isempty(coords)
            % Place features at selected coordinates
            featureResult = placeFeatureAtCoordinate(baseScenario, selectedFeature, coords(:,1), coords(:,2));
            
            % Extract the actual feature data and add metadata
            feature = featureResult.appliedFeatures;
            feature.color = featureColors(choice, :);
            feature.description = selectedDescription;
            
            % Add to collection
            if isempty(allFeatures)
                allFeatures = feature;
            else
                allFeatures(end+1) = feature;
            end
            
            % Update the display immediately
            figure(baseFig);
            hold on;
            scatter(coords(:,1), coords(:,2), 150, featureColors(choice, :), 'filled', ...
                'MarkerEdgeColor', 'k', 'LineWidth', 2);
            
            % Add feature labels
            for i = 1:size(coords, 1)
                text(coords(i,1)+10, coords(i,2)+10, selectedFeature(1:3), ...
                    'FontWeight', 'bold', 'Color', 'white', 'FontSize', 10, ...
                    'BackgroundColor', featureColors(choice, :), 'EdgeColor', 'k');
            end
            
            fprintf('✅ Placed %d %s features at selected coordinates\n', size(coords, 1), selectedFeature);
        else
            fprintf('⚠️  No coordinates selected for %s\n', selectedFeature);
        end
        
        % Ask if user wants to add more features
        try
            fprintf('\n❓ Would you like to add more features?\n');
            response = input('   Enter "y" for yes, anything else to finish: ', 's');
            continueAdding = strcmpi(response, 'y') || strcmpi(response, 'yes');
        catch
            % Fallback for batch mode
            continueAdding = false;
        end
    end

else
    % Batch mode - automatic placement
    fprintf('🤖 BATCH MODE: Automatic feature placement demo\n');
    fprintf('   (For interactive mode, run in MATLAB GUI)\n\n');
    
    % Predefined demo features with smart placement
    demoFeatures = [
        1, 3;  % 3 potholes
        2, 2;  % 2 barricade clusters  
        4, 1   % 1 rickshaw parking
    ];
    
    % Calculate coordinate bounds for smart placement
    xy = osmMeta.nodeXY;
    xRange = [min(xy(:,1)), max(xy(:,1))];
    yRange = [min(xy(:,2)), max(xy(:,2))];
    centerX = mean(xRange);
    centerY = mean(yRange);
    
    for demo_i = 1:size(demoFeatures, 1)
        featureIdx = demoFeatures(demo_i, 1);
        count = demoFeatures(demo_i, 2);
        
        selectedFeature = availableFeatures{featureIdx, 1};
        selectedDescription = availableFeatures{featureIdx, 2};
        
        fprintf('🎯 Auto-placing %d %s features...\n', count, selectedFeature);
        
        % Generate smart coordinates around road network center
        coords = zeros(count, 3);
        for i = 1:count
            % Random placement within central area
            angle = rand() * 2 * pi;
            radius = 100 + rand() * 200; % 100-300m from center
            coords(i, :) = [centerX + radius*cos(angle), centerY + radius*sin(angle), 0];
        end
        
        % Place features
        featureResult = placeFeatureAtCoordinate(baseScenario, selectedFeature, coords(:,1), coords(:,2));
        
        % Extract the actual feature data and add metadata
        feature = featureResult.appliedFeatures;
        feature.color = featureColors(featureIdx, :);
        feature.description = selectedDescription;
        
        % Add to collection
        if isempty(allFeatures)
            allFeatures = feature;
        else
            allFeatures(end+1) = feature;
        end
        
        % Update display
        figure(baseFig);
        hold on;
        scatter(coords(:,1), coords(:,2), 150, featureColors(featureIdx, :), 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 2);
        
        % Add labels
        for i = 1:size(coords, 1)
            text(coords(i,1)+10, coords(i,2)+10, selectedFeature(1:3), ...
                'FontWeight', 'bold', 'Color', 'white', 'FontSize', 10, ...
                'BackgroundColor', featureColors(featureIdx, :), 'EdgeColor', 'k');
        end
        
        fprintf('✅ Placed %d %s features automatically\n', count, selectedFeature);
    end
    
    fprintf('\n💡 For full interactive mode, run this script in MATLAB GUI\n');
end

%% Final Results Display
fprintf('\n🎉 Interactive Feature Placement Complete!\n');
fprintf('==========================================\n');

if ~isempty(allFeatures)
    % Create final enhanced visualization
    finalFig = figure('Name', 'Final Scenario with User-Placed Features', ...
        'Position', [150 150 1200 800]);
    
    % Plot base scenario
    plot(baseScenario);
    hold on;
    
    % Plot all placed features with legend
    legendEntries = {'Roads'};
    legendHandles = [];
    
    % Get first road handle for legend
    roadHandles = get(gca, 'Children');
    if ~isempty(roadHandles)
        legendHandles(1) = roadHandles(end); % First plotted (roads)
    end
    
    totalFeatures = 0;
    uniqueTypes = {};
    
    for i = 1:length(allFeatures)
        feature = allFeatures(i);
        coords = feature.positions;
        
        % Plot features
        h = scatter(coords(:,1), coords(:,2), 180, feature.color, 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 2);
        
        % Add to legend if it's a new type
        if ~ismember(feature.type, uniqueTypes)
            legendHandles(end+1) = h;
            legendEntries{end+1} = sprintf('%s (%d)', feature.type, feature.count);
            uniqueTypes{end+1} = feature.type;
        end
        
        % Add labels
        for j = 1:size(coords, 1)
            text(coords(j,1)+15, coords(j,2)+15, sprintf('%s-%d', feature.type(1:3), j), ...
                'FontWeight', 'bold', 'Color', 'white', 'FontSize', 9, ...
                'BackgroundColor', feature.color, 'EdgeColor', 'k');
        end
        
        totalFeatures = totalFeatures + feature.count;
    end
    
    % Enhance plot appearance
    axis equal; grid on;
    xlabel('X (meters)', 'FontSize', 12);
    ylabel('Y (meters)', 'FontSize', 12);
    title(sprintf('Final Scenario: %d User-Placed Features', totalFeatures), 'FontSize', 14);
    
    % Add legend
    if length(legendHandles) > 1
        legend(legendHandles, legendEntries, 'Location', 'best', 'FontSize', 10);
    end
    
    hold off;
    
    %% Save Results
    fprintf('\n💾 Saving results...\n');
    
    % Create output structure
    finalResults = struct();
    finalResults.scenario = baseScenario;
    finalResults.features = allFeatures;
    finalResults.osmMeta = osmMeta;
    finalResults.totalFeatures = totalFeatures;
    finalResults.uniqueFeatureTypes = uniqueTypes;
    finalResults.timestamp = datetime('now');
    
    % Save to dist directory
    distDir = fullfile(repoRoot, 'dist');
    if ~isfolder(distDir)
        mkdir(distDir);
    end
    
    % Save workspace
    matFile = fullfile(distDir, 'interactive_scenario.mat');
    save(matFile, 'finalResults', 'baseScenario', 'allFeatures', 'osmMeta');
    fprintf('✅ Scenario saved to: %s\n', matFile);
    
    % Save figure
    figFile = fullfile(distDir, 'interactive_scenario_plot.png');
    saveas(finalFig, figFile);
    fprintf('✅ Plot saved to: %s\n', figFile);
    
    % Create summary report
    reportFile = fullfile(distDir, 'interactive_scenario_report.txt');
    fid = fopen(reportFile, 'w');
    fprintf(fid, 'IND-DigitalTwin Interactive Feature Placement Report\n');
    fprintf(fid, '==================================================\n\n');
    fprintf(fid, 'Generated: %s\n', char(finalResults.timestamp));
    fprintf(fid, 'OSM File: %s\n', osmFile);
    fprintf(fid, 'Total Roads: %d\n', osmMeta.roadCreatedCount);
    fprintf(fid, 'Total Features Placed: %d\n', totalFeatures);
    fprintf(fid, '\nFeature Summary:\n');
    for i = 1:length(allFeatures)
        fprintf(fid, '- %s: %d instances\n', allFeatures(i).type, allFeatures(i).count);
    end
    fprintf(fid, '\nCoordinate Details:\n');
    for i = 1:length(allFeatures)
        fprintf(fid, '\n%s Coordinates:\n', allFeatures(i).type);
        coords = allFeatures(i).positions;
        for j = 1:size(coords, 1)
            fprintf(fid, '  %.2f, %.2f\n', coords(j,1), coords(j,2));
        end
    end
    fclose(fid);
    fprintf('✅ Report saved to: %s\n', reportFile);
    
    %% Final Summary
    fprintf('\n🎯 FINAL SUMMARY\n');
    fprintf('================\n');
    fprintf('📍 Total Features Placed: %d\n', totalFeatures);
    fprintf('🎨 Feature Types Used: %s\n', strjoin(uniqueTypes, ', '));
    fprintf('💾 Results saved to: %s\n', distDir);
    
    % Expose to workspace
    assignin('base', 'interactiveScenario', finalResults);
    fprintf('📊 Results available in workspace as: interactiveScenario\n');
    
else
    fprintf('⚠️  No features were placed during this session.\n');
end

fprintf('\n🎉 Interactive Demo Complete!\n');
fprintf('Thank you for using IND-DigitalTwin Interactive Feature Placement!\n');
