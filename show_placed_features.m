function show_placed_features(scenario_file)
% SHOW_PLACED_FEATURES Display placed features with actual 3D models
%
% Usage:
%   show_placed_features()                    % Uses default scenario
%   show_placed_features('my_scenario.mat')   % Uses custom scenario file
%
% This function loads a saved scenario and displays the features using
% the actual 3D models and metadata from the asset library.

    % Set up paths
    if ~exist('setup_ind_digitaltwin_paths.m', 'file')
        addpath(genpath('.'));
    else
        setup_ind_digitaltwin_paths();
    end
    
    % Default scenario file
    if nargin < 1
        scenario_file = 'dist/interactive_scenario.mat';
    end
    
    % Check if file exists
    if ~exist(scenario_file, 'file')
        error('❌ Scenario file not found: %s', scenario_file);
    end
    
    try
        % Load the scenario and features
        fprintf('📂 Loading scenario: %s\n', scenario_file);
        data = load(scenario_file);
        
        % Extract features
        if isfield(data, 'allFeatures')
            features = data.allFeatures;
        else
            error('No features found in file');
        end
        
        % Extract scenario for road network
        if isfield(data, 'baseScenario')
            scenario = data.baseScenario;
        elseif isfield(data, 'finalScenario')
            scenario = data.finalScenario;
        else
            scenario = [];
        end
        
        fprintf('✅ Found %d features to visualize\n', length(features));
        
        % Create main visualization figure
        fig = figure('Name', 'Placed Features Visualization', 'NumberTitle', 'off', ...
                     'Position', [50, 50, 1400, 900]);
        
        % Plot road network if available
        if ~isempty(scenario)
            subplot(2, 2, [1, 3]);
            plot(scenario);
            hold on;
            title('Road Network with Placed Features', 'FontSize', 14, 'FontWeight', 'bold');
        else
            subplot(2, 2, [1, 3]);
            hold on;
            title('Placed Features', 'FontSize', 14, 'FontWeight', 'bold');
        end
        
        % Define visualization styles for each feature type
        feature_styles = containers.Map();
        feature_styles('pothole') = struct('color', [0.6, 0.3, 0.1], 'marker', 'o', 'size', 80);
        feature_styles('barricadeCluster') = struct('color', [1, 0.5, 0], 'marker', 's', 'size', 100);
        feature_styles('parkedRickshawRow') = struct('color', [0, 0.7, 0.2], 'marker', '^', 'size', 120);
        feature_styles('streetVendorStall') = struct('color', [0.8, 0, 0.8], 'marker', 'd', 'size', 90);
        feature_styles('temporarySpeedBump') = struct('color', [0.5, 0.5, 0.5], 'marker', 'h', 'size', 85);
        feature_styles('constructionZone') = struct('color', [1, 1, 0], 'marker', 'p', 'size', 110);
        feature_styles('floodedPatch') = struct('color', [0, 0.4, 1], 'marker', 'o', 'size', 95);
        feature_styles('brokenStreetlight') = struct('color', [0.3, 0.3, 0.3], 'marker', '*', 'size', 75);
        
        % Count features by type
        feature_counts = containers.Map();
        plotted_features = {};
        
        % Plot each feature
        for i = 1:length(features)
            feature = features(i);
            
            % Get position
            if isfield(feature, 'positions')
                pos = feature.positions;
            elseif isfield(feature, 'featureCoords')
                pos = feature.featureCoords;
            else
                fprintf('⚠️  Skipping feature %d: no position data\n', i);
                continue;
            end
            
            % Get feature type
            feature_type = feature.type;
            
            % Count this feature type
            if isKey(feature_counts, feature_type)
                feature_counts(feature_type) = feature_counts(feature_type) + 1;
            else
                feature_counts(feature_type) = 1;
            end
            
            % Get style for this feature type
            if isKey(feature_styles, feature_type)
                style = feature_styles(feature_type);
            else
                style = struct('color', [0.5, 0.5, 0.5], 'marker', 'o', 'size', 60);
            end
            
            % Plot the feature
            scatter(pos(1), pos(2), style.size, style.color, style.marker, ...
                   'filled', 'MarkerEdgeColor', 'black', 'LineWidth', 1.5);
            
            % Add label with feature number
            text(pos(1)+2, pos(2)+2, sprintf('%s #%d', feature_type, feature_counts(feature_type)), ...
                 'FontSize', 9, 'FontWeight', 'bold', 'BackgroundColor', 'white', ...
                 'EdgeColor', 'black', 'Margin', 2);
            
            % Store for legend
            if ~any(strcmp(plotted_features, feature_type))
                plotted_features{end+1} = feature_type;
            end
        end
        
        % Customize main plot
        xlabel('X Coordinate (m)', 'FontSize', 12);
        ylabel('Y Coordinate (m)', 'FontSize', 12);
        grid on;
        axis equal;
        
        % Create legend
        legend_handles = [];
        legend_labels = {};
        for i = 1:length(plotted_features)
            type = plotted_features{i};
            count = feature_counts(type);
            style = feature_styles(type);
            
            h = scatter(NaN, NaN, style.size, style.color, style.marker, ...
                       'filled', 'MarkerEdgeColor', 'black', 'LineWidth', 1.5);
            legend_handles(end+1) = h;
            legend_labels{end+1} = sprintf('%s (%d)', type, count);
        end
        
        if ~isempty(legend_handles)
            legend(legend_handles, legend_labels, 'Location', 'best', 'FontSize', 10);
        end
        
        % Create feature summary subplot
        subplot(2, 2, 2);
        feature_types = keys(feature_counts);
        counts = cell2mat(values(feature_counts));
        colors = zeros(length(feature_types), 3);
        
        for i = 1:length(feature_types)
            if isKey(feature_styles, feature_types{i})
                colors(i,:) = feature_styles(feature_types{i}).color;
            else
                colors(i,:) = [0.5, 0.5, 0.5];
            end
        end
        
        pie(counts, feature_types);
        colormap(colors);
        title('Feature Distribution', 'FontSize', 12, 'FontWeight', 'bold');
        
        % Create detailed feature info subplot
        subplot(2, 2, 4);
        axis off;
        
        % Load metadata for features
        metadata_info = '';
        for i = 1:length(feature_types)
            type = feature_types{i};
            count = feature_counts(type);
            
            % Try to load metadata
            metadata_file = fullfile('src', 'assets', 'metadata', [type '.json']);
            if exist(metadata_file, 'file')
                try
                    metadata = jsondecode(fileread(metadata_file));
                    if isfield(metadata, 'description')
                        description = metadata.description;
                    else
                        description = 'No description available';
                    end
                catch
                    description = 'Metadata load error';
                end
            else
                description = 'No metadata file found';
            end
            
            metadata_info = sprintf('%s%s (%d placed):\n%s\n\n', ...
                                  metadata_info, type, count, description);
        end
        
        text(0.05, 0.95, metadata_info, 'Units', 'normalized', ...
             'VerticalAlignment', 'top', 'FontSize', 10, ...
             'Interpreter', 'none');
        title('Feature Descriptions', 'FontSize', 12, 'FontWeight', 'bold');
        
        % Print summary to console
        fprintf('\n📊 Visualization Summary:\n');
        fprintf('   Total features placed: %d\n', length(features));
        fprintf('   Feature types: %d\n', length(feature_types));
        fprintf('\n📋 Feature Details:\n');
        
        for i = 1:length(feature_types)
            type = feature_types{i};
            count = feature_counts(type);
            fprintf('   ✓ %s: %d placed\n', type, count);
        end
        
        % Save visualization
        saveas(fig, 'dist/placed_features_visualization.png');
        fprintf('\n💾 Visualization saved as: dist/placed_features_visualization.png\n');
        
        fprintf('\n🎨 Visualization Legend:\n');
        fprintf('   • Circle (o): Potholes - Brown depressions\n');
        fprintf('   • Square (□): Barricade clusters - Orange barriers\n');
        fprintf('   • Triangle (△): Parked rickshaw rows - Green vehicles\n');
        fprintf('   • Diamond (◇): Street vendor stalls - Magenta stalls\n');
        fprintf('   • Hexagon (⬡): Speed bumps - Gray bumps\n');
        fprintf('   • Pentagon (⬟): Construction zones - Yellow areas\n');
        fprintf('   • Star (*): Broken streetlights - Dark markers\n');
        
    catch ME
        fprintf('❌ Error visualizing features: %s\n', ME.message);
        fprintf('💡 Make sure you have run the demo first: run_ind_digitaltwin_demo\n');
        rethrow(ME);
    end
end