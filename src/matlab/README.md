# MATLAB Source Code

This directory contains the core MATLAB functions implementing the IND-DigitalTwin scenario generation pipeline.

## Core Functions

### Main Pipeline
- **[`generateScenarioFromConfig.m`](./generateScenarioFromConfig.m)**: Main entry point - loads config and orchestrates scenario generation
- **[`buildScenarioFromOSM.m`](./buildScenarioFromOSM.m)**: OSM parser that creates road networks from OpenStreetMap data
- **[`augmentScenario.m`](./augmentScenario.m)**: Places Indian micro-features on the road network using geometry-aware rules

### Traffic & Behavior
- **[`spawnTraffic.m`](./spawnTraffic.m)**: Multi-class Poisson traffic generation with realistic arrival patterns
- **[`applyBehaviorProfiles.m`](./applyBehaviorProfiles.m)**: Assigns driving behavior profiles to vehicles (aggression, speed, etc.)

### Visualization & Export
- **[`plotAppliedFeatures.m`](./plotAppliedFeatures.m)**: Visualizes road network with overlaid micro-features
- **[`collectMetrics.m`](./collectMetrics.m)**: Extracts scenario statistics and performance metrics
- **[`exportScenarioReport.m`](./exportScenarioReport.m)**: Generates comprehensive scenario reports

### Utilities
- **[`generateScenarioSet.m`](./generateScenarioSet.m)**: Creates multiple scenario variations with different random seeds
- **[`prepareHackathonPackage.m`](./prepareHackathonPackage.m)**: Packages scenarios and reports for distribution

## Function Dependencies

```
generateScenarioFromConfig.m (Main)
├── buildScenarioFromOSM.m
├── augmentScenario.m
├── spawnTraffic.m
├── applyBehaviorProfiles.m
├── plotAppliedFeatures.m
├── collectMetrics.m
└── exportScenarioReport.m
```

## Key Data Structures

### Configuration Object
Loaded from JSON, validated against schema:
```matlab
config.geometry          % OSM file path and settings
config.microFeatures     % Feature placement specifications  
config.behaviorProfiles  % Driving behavior definitions
config.trafficDemand     % Traffic generation parameters
```

### Output Structure
Returned by `generateScenarioFromConfig`:
```matlab
out.scenario            % MATLAB drivingScenario object
out.features           % Applied micro-feature locations
out.osmMeta           % OSM parsing metadata
out.vehicles          % Spawned vehicle information
out.metrics           % Scenario statistics
```

## Usage Examples

### Basic Scenario Generation
```matlab
% Load and generate from config
out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');

% Visualize results
plot(out.scenario);
plotAppliedFeatures(out.scenario, out.features);
```

### Component Usage
```matlab
% Build road network only
scenario = buildScenarioFromOSM('data/osm/sample_map.osm');

% Add features to existing scenario
features = augmentScenario(scenario, config.microFeatures);

% Generate traffic
vehicles = spawnTraffic(scenario, config.trafficDemand, config.behaviorProfiles);
```

### Batch Processing
```matlab
% Generate multiple variations  
scenarios = generateScenarioSet('configs/examples/delhi_osm_demo.json', 5);

% Process all scenarios
for i = 1:length(scenarios)
    metrics = collectMetrics(scenarios{i});
    exportScenarioReport(scenarios{i}, sprintf('scenario_%d_report', i));
end
```

## Development Guidelines

### Error Handling
- Validate inputs at function entry
- Provide meaningful error messages
- Check for required toolboxes and dependencies

### Performance
- Cache expensive operations (OSM parsing, coordinate projection)
- Use vectorized operations where possible
- Limit memory usage for large road networks

### Code Style
- Use descriptive variable names
- Comment complex algorithms
- Follow MATLAB naming conventions
- Include function documentation headers

## Extending the System

### Adding New Feature Types
1. Create metadata in [`../assets/metadata/`](../assets/metadata/)
2. Features automatically available - no code changes needed
3. Custom placement rules require updates to `augmentScenario.m`

### Enhancing OSM Support
- Modify `buildScenarioFromOSM.m` for additional OSM tags
- Add lane count inference, elevation data, traffic signals
- Implement proper coordinate projection for large areas

### Custom Behavior Models
- Extend `applyBehaviorProfiles.m` for new behavioral parameters
- Integrate with MATLAB's IDM/Gipps longitudinal models
- Add lateral behavior modeling (lane changing, gap acceptance)

## Dependencies

**Required MATLAB Products:**
- MATLAB R2025b or later
- Automated Driving Toolbox

**Required Functions:**
- `drivingScenario` class and methods
- `road()` for network building
- JSON parsing utilities

**File System Dependencies:**
- [`../assets/`](../assets/) directory for feature definitions
- Configuration schema validation
- OSM data file access