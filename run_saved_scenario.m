function run_saved_scenario(scenario_file)
% RUN_SAVED_SCENARIO Load scenario with visible features for simulation
%
% Usage:
%   run_saved_scenario()                    % Uses default scenario
%   run_saved_scenario('my_scenario.mat')   % Uses custom scenario file
%
% This function loads a saved IND-DigitalTwin scenario, adds the features
% as visible actors, and opens it in drivingScenarioDesigner where you can
% add an ego vehicle and run the simulation to see all features clearly.

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
        available_files = dir('dist/*.mat');
        if isempty(available_files)
            error('No scenario files found in dist/ directory. Run the demo first with: run_ind_digitaltwin_demo');
        end
        
        fprintf('❌ File not found: %s\n', scenario_file);
        fprintf('📁 Available scenario files:\n');
        for i = 1:length(available_files)
            fprintf('   - %s\n', available_files(i).name);
        end
        return;
    end
    
    try
        % Load the scenario and features
        fprintf('📂 Loading scenario: %s\n', scenario_file);
        loaded_data = load(scenario_file);
        
        % Extract base scenario
        base_scenario = [];
        scenario_var_names = {'baseScenario', 'finalScenario', 'scenario', 'drivingScenario'};
        
        for i = 1:length(scenario_var_names)
            if isfield(loaded_data, scenario_var_names{i})
                base_scenario = loaded_data.(scenario_var_names{i});
                fprintf('✅ Found scenario variable: %s\n', scenario_var_names{i});
                break;
            end
        end
        
        % Extract features
        features = [];
        if isfield(loaded_data, 'allFeatures')
            features = loaded_data.allFeatures;
            fprintf('✅ Found %d features to add as visible actors\n', length(features));
        end
        
        if isempty(base_scenario)
            field_names = fieldnames(loaded_data);
            fprintf('❌ Could not find scenario variable. Available variables:\n');
            for i = 1:length(field_names)
                fprintf('   - %s\n', field_names{i});
            end
            return;
        end
        
        % Create enhanced scenario with visible features
        fprintf('🔧 Creating scenario with visible features...\n');
        enhanced_scenario = create_scenario_with_visible_features(base_scenario, features);
        
        % Check if Automated Driving Toolbox is available
        if license('test', 'Automated_Driving_Toolbox')
            fprintf('🚗 Opening enhanced scenario in drivingScenarioDesigner...\n');
            drivingScenarioDesigner(enhanced_scenario);
            
            fprintf('\n✅ SUCCESS! Scenario opened with visible features!\n');
            fprintf('\n🎮 Next Steps:\n');
            fprintf('   1️⃣  In the drivingScenarioDesigner:\n');
            fprintf('       • Add an ego vehicle by clicking "Add Ego Vehicle"\n');
            fprintf('       • Set a path for your ego vehicle\n');
            fprintf('   2️⃣  Click the Play ▶️ button to start simulation\n');
            fprintf('   3️⃣  Your features are visible as colored objects:\n');
            fprintf('       🟤 Dark Brown = Potholes (slightly below road)\n');
            fprintf('       🟠 Orange = Barricade clusters (above road)\n');
            fprintf('       🟢 Green = Parked rickshaws (at road level)\n');
            fprintf('       🟡 Yellow = Construction zones\n');
            fprintf('       🔵 Blue = Flooded patches\n');
            fprintf('       ⚫ Dark Gray = Broken streetlights (elevated)\n');
            fprintf('   4️⃣  Use camera controls to get the best view\n');
            fprintf('\n💡 Pro Tips:\n');
            fprintf('   • Right-click + drag to rotate camera view\n');
            fprintf('   • Mouse wheel to zoom in/out on features\n');
            fprintf('   • Try "Chase" camera mode to follow ego vehicle\n');
            fprintf('   • Adjust simulation speed for better observation\n');
            
        else
            fprintf('❌ Automated Driving Toolbox not available\n');
            fprintf('📊 Enhanced scenario created and available in workspace\n');
            
            % Show basic plot
            try
                figure('Name', 'Enhanced Scenario with Features', 'NumberTitle', 'off');
                plot(enhanced_scenario);
                title('Scenario with Visible Features');
                fprintf('� Scenario plot created - see figure window\n');
            catch
                fprintf('⚠️  Could not create plot\n'); 
            end
        end
        
    catch ME
        fprintf('❌ Error loading scenario: %s\n', ME.message);
        fprintf('💡 Make sure the file contains a valid drivingScenario object.\n');
        rethrow(ME);
    end
end

function enhanced_scenario = create_scenario_with_visible_features(base_scenario, features)
% Create enhanced scenario with features as visible stationary actors
    
    % Create new driving scenario
    enhanced_scenario = drivingScenario('SampleTime', 0.1, 'StopTime', 60);
    
    % Create road network based on feature positions
    if ~isempty(features)
        % Get all feature positions
        all_positions = [];
        for i = 1:length(features)
            if isfield(features(i), 'positions')
                all_positions = [all_positions; features(i).positions];
            elseif isfield(features(i), 'featureCoords')
                all_positions = [all_positions; features(i).featureCoords];
            end
        end
        
        if ~isempty(all_positions)
            % Create road network that encompasses all features
            min_x = min(all_positions(:,1)) - 50;
            max_x = max(all_positions(:,1)) + 50;
            min_y = min(all_positions(:,2)) - 50;
            max_y = max(all_positions(:,2)) + 50;
            
            % Create cross-shaped road network
            center_x = (min_x + max_x) / 2;
            center_y = (min_y + max_y) / 2;
            
            % Main horizontal road
            roadCenters1 = [min_x, center_y; max_x, center_y];
            road(enhanced_scenario, roadCenters1, 'lanes', lanespec(2));
            
            % Main vertical road  
            roadCenters2 = [center_x, min_y; center_x, max_y];
            road(enhanced_scenario, roadCenters2, 'lanes', lanespec(2));
            
            fprintf('✅ Created road network covering area: [%.1f,%.1f] to [%.1f,%.1f]\n', ...
                    min_x, min_y, max_x, max_y);
        end
    else
        % Default road network if no features
        roadCenters = [0 0; 100 0; 100 100; 0 100; 0 0];
        road(enhanced_scenario, roadCenters, 'lanes', lanespec(2));
    end
    
    % Add features as visible stationary actors
    if ~isempty(features)
        actors_added = 0;
        
        for i = 1:length(features)
            feature = features(i);
            
            % Get feature position
            if isfield(feature, 'positions')
                pos = feature.positions;
            elseif isfield(feature, 'featureCoords')
                pos = feature.featureCoords;
            else
                continue;
            end
            
            % Get feature type
            feature_type = feature.type;
            
            try
                % Set actor appearance based on feature type
                switch feature_type
                    case 'pothole'
                        color = [0.3, 0.2, 0.1]; % Dark brown
                        classID = 1;
                        z_offset = -0.15; % Below road level
                        
                    case 'barricadeCluster'
                        color = [1, 0.4, 0]; % Bright orange
                        classID = 2; % Truck class for larger size
                        z_offset = 0.5; % Above road level
                        
                    case 'parkedRickshawRow'
                        color = [0, 0.6, 0.1]; % Green
                        classID = 1;
                        z_offset = 0; % Road level
                        
                    case 'streetVendorStall'
                        color = [0.7, 0, 0.7]; % Magenta
                        classID = 1;
                        z_offset = 0.3;
                        
                    case 'temporarySpeedBump'
                        color = [0.6, 0.6, 0.6]; % Gray
                        classID = 1;
                        z_offset = 0.1;
                        
                    case 'constructionZone'
                        color = [1, 0.8, 0]; % Bright yellow
                        classID = 2; % Truck for visibility
                        z_offset = 0.2;
                        
                    case 'floodedPatch'
                        color = [0, 0.3, 0.8]; % Blue
                        classID = 1;
                        z_offset = 0.05;
                        
                    case 'brokenStreetlight'
                        color = [0.2, 0.2, 0.2]; % Dark gray
                        classID = 1;
                        z_offset = 2.0; % High above road
                        
                    otherwise
                        color = [0.5, 0.5, 0.5];
                        classID = 1;
                        z_offset = 0.3;
                end
                
                % Create stationary vehicle actor at feature location
                actor = vehicle(enhanced_scenario, 'ClassID', classID, ...
                       'Position', [pos(1), pos(2), z_offset]);
                
                % Set visual properties
                actor.PlotColor = color;
                actor.Name = sprintf('%s_%d', feature_type, i);
                
                % Actor is stationary by default (no trajectory added)
                actors_added = actors_added + 1;
                
                fprintf('✓ Added visible %s at [%.1f, %.1f, %.2f]\n', ...
                        feature_type, pos(1), pos(2), z_offset);
                
            catch ME_actor
                fprintf('⚠️  Could not add %s: %s\n', feature_type, ME_actor.message);
            end
        end
        
        fprintf('✅ Added %d features as visible actors\n', actors_added);
    end
end