# IND-DigitalTwin Usage Guide

Complete guide for running the IND-DigitalTwin system in different modes and environments.

## Running Modes

### 1. Automatic Demo Mode (Universal)
**Best for:** First-time users, batch processing, non-GUI environments

```matlab
% From project root directory
run_ind_digitaltwin_demo
```

**What it does:**
- ✅ Works in ALL MATLAB environments (batch, GUI, server)
- 🗺️ Loads `data/osm/sample_map.osm` road network
- 🤖 Automatically places 6 diverse features:
  - 3 potholes at strategic locations
  - 2 barricade clusters near intersections  
  - 1 parked rickshaw area
- 🎨 Generates visualization with color-coded features
- 💾 Saves complete scenario to `dist/interactive_scenario.mat`
- 📊 Creates summary plot as `dist/interactive_scenario_plot.png`

### 2. Interactive GUI Mode (Desktop Only)
**Best for:** Custom feature placement, interactive exploration

```matlab
% Requires MATLAB Desktop with figure windows
run_interactive_feature_demo
```

**What you can do:**
- 🖱️ Click anywhere on the map to place features
- 📋 Choose from 8 Indian micro-features (potholes, barricades, etc.)
- 🔄 Place multiple features in one session
- 🎨 See real-time updates as you add features
- 💾 Save custom scenarios with your placements

### 3. Direct Programming Mode (Advanced)
**Best for:** Scripting, precise coordinate control, automation

```matlab
% Place single feature at exact coordinates
[scenario, result] = placeFeatureAtCoordinate([28.6448, 77.2167], 'pothole');

% Batch placement with custom features
coordinates = [28.6448, 77.2167; 28.6450, 77.2170; 28.6452, 77.2175];
for i = 1:size(coordinates, 1)
    [scenario, result] = placeFeatureAtCoordinate(coordinates(i,:), 'barricadeCluster');
end
```

## Environment Compatibility

| Environment | Auto Demo | Interactive GUI | Direct Programming |
|-------------|-----------|-----------------|-------------------|
| MATLAB Desktop | ✅ | ✅ | ✅ |
| MATLAB Online | ✅ | ❌* | ✅ |
| MATLAB Batch/Server | ✅ | ❌ | ✅ |
| Command Line | ✅ | ❌ | ✅ |

*Interactive GUI requires figure window support

## Output Files

All outputs are saved to the `dist/` directory:

### Automatic Demo Outputs
```
dist/
├── interactive_scenario.mat          # Complete MATLAB scenario
├── interactive_scenario_plot.png     # Visualization
└── feature_placement_report.txt      # Detailed placement log
```

### Interactive GUI Outputs  
```
dist/
├── custom_scenario_YYYYMMDD_HHMMSS.mat    # Timestamp-named scenario
├── custom_scenario_YYYYMMDD_HHMMSS.png    # Visualization
└── placement_log_YYYYMMDD_HHMMSS.txt      # Your placement history
```

## Available Features

| Feature Type | Description | Use Case |
|--------------|-------------|----------|
| `pothole` | Road surface damage | Traffic slowdowns, vehicle damage |
| `barricadeCluster` | Construction barriers | Road closures, diversions |
| `parkedRickshawRow` | Parked auto-rickshaws | Lane blockage, urban congestion |
| `streetVendorStall` | Roadside vendors | Pedestrian areas, market zones |
| `temporarySpeedBump` | Traffic calming | Speed control areas |
| `constructionZone` | Active construction | Major road disruptions |
| `floodedPatch` | Water accumulation | Monsoon conditions |
| `brokenStreetlight` | Non-functional lighting | Safety concerns, night visibility |

## Troubleshooting

### Common Issues

**Q: "Error: Could not load OSM file"**
```matlab
% Check if file exists and run setup
if ~exist('data/osm/sample_map.osm', 'file')
    error('OSM file not found. Check your working directory.');
end
setup_ind_digitaltwin_paths();  % Ensure paths are set
```

**Q: "Interactive mode not working"**
```matlab
% Check GUI availability
if usejava('desktop') && feature('ShowFigureWindows')
    disp('GUI mode available - use run_interactive_feature_demo');
else
    disp('GUI not available - use run_ind_digitaltwin_demo');
end
```

**Q: "No features were placed"**
- Check that coordinates fall within your OSM boundaries
- Verify feature types match available options
- Ensure sufficient road network density

### Performance Tips

1. **Large OSM Files:** Use smaller map areas for interactive mode
2. **Many Features:** Batch mode is faster for >10 features  
3. **Custom Maps:** Validate OSM file with MATLAB before use

## Integration Examples

### With Automated Driving Toolbox
```matlab
% Run demo and extract scenario
run_ind_digitaltwin_demo;
load('dist/interactive_scenario.mat', 'finalScenario');

% Use in Automated Driving Toolbox
simulator = drivingScenarioDesigner(finalScenario);
```

### With Custom Analysis
```matlab
% Generate scenario and analyze
run_ind_digitaltwin_demo;
load('dist/interactive_scenario.mat', 'allFeatures');

% Extract feature statistics
feature_counts = countcats(categorical({allFeatures.type}));
disp('Feature distribution:');
disp(feature_counts);
```

### Batch Processing Multiple Maps
```matlab
osm_files = {'map1.osm', 'map2.osm', 'map3.osm'};
for i = 1:length(osm_files)
    % Process each map
    copyfile(osm_files{i}, 'data/osm/sample_map.osm');
    run_ind_digitaltwin_demo;
    
    % Rename outputs
    movefile('dist/interactive_scenario.mat', ...
             sprintf('dist/scenario_%d.mat', i));
end
```

## Next Steps

1. **First Run:** Try `run_ind_digitaltwin_demo` to see the system in action
2. **Custom Features:** Use `run_interactive_feature_demo` for hands-on placement
3. **Your Data:** Replace `data/osm/sample_map.osm` with your own OSM file
4. **Integration:** Load generated scenarios into your traffic simulation pipeline

For detailed technical information, see [`../src/matlab/README.md`](../src/matlab/README.md).