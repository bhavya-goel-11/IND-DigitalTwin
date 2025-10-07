# Data Directory

This directory contains input data files used by the IND-DigitalTwin toolkit.

## Structure

### [`osm/`](./osm/)
OpenStreetMap data files containing road network geometry.
- Input source for road network topology
- Contains sample Delhi junction data
- See [osm/README.md](./osm/README.md) for detailed usage instructions

## Data Flow

```
OSM Files (data/osm/) 
    ↓
OSM Parser (src/matlab/buildScenarioFromOSM.m)
    ↓
MATLAB drivingScenario Object
    ↓
Feature Placement & Traffic Generation
    ↓
Complete Digital Twin Scenario
```

## Adding New Data Sources

The toolkit is designed to be extensible. Currently supports:
- **OSM data**: Road network geometry and topology

Future data sources could include:
- Traffic count data
- Signal timing plans  
- Elevation/terrain data
- Real-time traffic feeds

## File Organization

Keep data organized by:
- **Source type**: `osm/`, `traffic/`, `elevation/` (future)
- **Geographic area**: Descriptive filenames
- **Time period**: Date stamps for time-series data

## Data Preprocessing

OSM data is processed automatically by the toolkit:
1. Node coordinate extraction and projection
2. Highway way parsing and classification  
3. Road network topology building
4. Lane specification by road type

No manual preprocessing required for standard OSM exports.

## Usage in Configurations

Reference data files in configuration JSON:
```json
{
  "geometry": {
    "source": "osm",
    "osmFile": "data/osm/your_file.osm"
  }
}
```

Paths are relative to project root directory.