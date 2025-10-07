# Configuration Files

This directory contains the JSON configuration files that define scenarios for the IND-DigitalTwin toolkit.

## Files

### [`schema.json`](./schema.json)
Complete JSON schema definition for scenario configuration files. This defines:
- Required and optional fields
- Data types and validation rules
- Structure for geometry, micro-features, behavior profiles, and traffic demand

### [`examples/`](./examples/)
Example configuration files demonstrating different scenario types:
- **[`delhi_osm_demo.json`](./examples/delhi_osm_demo.json)**: OSM-based Delhi junction scenario with Indian micro-features

## Configuration Structure

All configuration files follow this basic structure:

```json
{
  "geometry": {
    "source": "osm",
    "osmFile": "data/osm/your_map.osm"
  },
  "microFeatures": [
    {"type": "pothole", "count": 6, "placementRule": "nearStopLine"},
    {"type": "barricadeCluster", "count": 1, "placementRule": "approachNorth"}
  ],
  "behaviorProfiles": [
    {"id": "car_default", "vehicleClass": "car", "aggression": 0.5}
  ],
  "trafficDemand": {
    "timeHorizon": 300,
    "arrivalStreams": [...]
  },
  "variation": {"count": 3, "seed": 42},
  "export": {"matScenario": true, "report": true}
}
```

## Creating New Configurations

1. Copy an existing example file from [`examples/`](./examples/)
2. Modify the `geometry.osmFile` path to your OSM file
3. Adjust micro-feature counts and placement rules as needed
4. Update traffic demand parameters for your scenario
5. Save with a descriptive filename ending in `.json`

## Validation

All configuration files are validated against [`schema.json`](./schema.json) when loaded. If validation fails, check:
- Required fields are present
- Data types match the schema
- File paths exist (especially OSM files)
- Placement rules are valid (see [`../src/assets/metadata/`](../src/assets/metadata/) for supported rules)

## Usage

Configuration files are used by the main generation pipeline:

```matlab
% Load and generate scenario from config
out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');
```