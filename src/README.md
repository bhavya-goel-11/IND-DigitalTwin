# Source Code Directory

This directory contains the core MATLAB implementation of the IND-DigitalTwin toolkit.

## Structure

### [`assets/`](./assets/)
Asset definitions and 3D models for Indian micro-features:
- **[`metadata/`](./assets/metadata/)**: JSON metadata files defining feature properties and placement rules
- **[`models/`](./assets/models/)**: 3D model files (.mat, .stl) for visual representation

### [`matlab/`](./matlab/)
Core MATLAB functions and scripts:
- **Scenario generation pipeline**
- **OSM parsing and road network building**  
- **Feature placement and augmentation**
- **Traffic spawning and behavior modeling**
- **Visualization and reporting utilities**

## Architecture Overview

```
Configuration (JSON)
        ↓
generateScenarioFromConfig.m (Main Pipeline)
        ↓
┌─────────────────┬─────────────────┬─────────────────┐
│   Geometry      │   Features      │    Traffic      │
│ (OSM → Roads)   │  (Placement)    │  (Spawning)     │
└─────────────────┴─────────────────┴─────────────────┘
        ↓
Complete drivingScenario + Metadata
        ↓
Visualization & Export
```

## Key Components

1. **Geometry Builder** ([`matlab/buildScenarioFromOSM.m`](./matlab/buildScenarioFromOSM.m))
   - Parses OSM XML files
   - Projects geographic coordinates to local coordinate system
   - Creates MATLAB road network from highway ways

2. **Feature Augmentation** ([`matlab/augmentScenario.m`](./matlab/augmentScenario.m))
   - Places Indian micro-features (potholes, barricades, etc.)
   - Uses geometry-aware heuristic placement rules
   - Reads feature definitions from [`assets/metadata/`](./assets/metadata/)

3. **Traffic Generation** ([`matlab/spawnTraffic.m`](./matlab/spawnTraffic.m))
   - Multi-class Poisson arrival process
   - Behavior profile assignment
   - Vehicle path planning through road network

4. **Visualization** ([`matlab/plotAppliedFeatures.m`](./matlab/plotAppliedFeatures.m))
   - Overlays features on road network
   - Color-coded feature types
   - Interactive scenario visualization

## Development Workflow

### Adding New Features
1. Create metadata file in [`assets/metadata/`](./assets/metadata/)
2. Add 3D model in [`assets/models/`](./assets/models/) (optional)
3. Features automatically available in configurations

### Extending OSM Support
- Modify [`matlab/buildScenarioFromOSM.m`](./matlab/buildScenarioFromOSM.m)
- Add support for additional OSM tags
- Enhance coordinate projection for larger areas

### Custom Placement Rules
- Extend placement logic in [`matlab/augmentScenario.m`](./matlab/augmentScenario.m)
- Add new rule types in feature metadata
- Update schema validation if needed

## Dependencies

**Required MATLAB Products**:
- MATLAB R2025b or later
- Automated Driving Toolbox

**Key MATLAB Functions Used**:
- `drivingScenario` - Core scenario representation
- `road()` - Road network building
- Coordinate system and geometry utilities

## File Naming Conventions

- **Functions**: `camelCase.m` (e.g., `generateScenarioFromConfig.m`)
- **Scripts**: `snake_case.m` for standalone scripts
- **Assets**: Descriptive names matching feature types
- **Configurations**: Geographic or purpose-based naming

## Testing and Validation

Run the complete pipeline with:
```matlab
addpath('src/matlab');
run_ind_digitaltwin_demo
```

For component testing:
```matlab
% Test OSM parsing
scenario = buildScenarioFromOSM('data/osm/sample_map.osm');

% Test feature placement  
features = augmentScenario(scenario, config.microFeatures);

% Test visualization
plotAppliedFeatures(scenario, features);
```