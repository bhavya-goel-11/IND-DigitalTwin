# Example Configuration Files

This directory contains ready-to-use example configuration files demonstrating different scenario types.

## Available Examples

### [`delhi_osm_demo.json`](./delhi_osm_demo.json)
**Complete OSM-based Delhi junction scenario**

- **Geometry**: Uses sample OSM data from [`../../data/osm/sample_map.osm`](../../data/osm/sample_map.osm)
- **Features**: Includes potholes, barricade clusters, and parked rickshaw rows
- **Traffic**: Multi-class vehicle mix (cars, two-wheelers, three-wheelers)
- **Behavior**: Realistic Indian driving behavior profiles with varying aggression levels

**Quick start with this example**:
```matlab
% From MATLAB command window (from project root)
addpath('src/matlab');
out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');
plot(out.scenario);
plotAppliedFeatures(out.scenario, out.features);
```

## Using These Examples

1. **As templates**: Copy any example and modify for your specific needs
2. **Direct usage**: Run examples as-is to see system capabilities
3. **Learning**: Study the structure to understand configuration options

## Customizing Examples

To adapt an example for your area:

1. **Replace OSM file**:
   ```json
   "geometry": {
     "source": "osm",
     "osmFile": "data/osm/your_area.osm"  // Change this path
   }
   ```

2. **Adjust micro-features**:
   ```json
   "microFeatures": [
     {"type": "pothole", "count": 3},      // Reduce/increase counts
     {"type": "barricadeCluster", "count": 1}
   ]
   ```

3. **Modify traffic patterns**:
   ```json
   "trafficDemand": {
     "arrivalStreams": [
       {"entryId": "west_in", "ratePerHour": 600}  // Adjust rates
     ]
   }
   ```

## Validation

All examples are pre-validated against the schema in [`../schema.json`](../schema.json). They should run without errors if:
- Required MATLAB toolboxes are installed
- Referenced OSM files exist
- Asset metadata is properly populated

For troubleshooting, see the main project [README](../../README.md#troubleshooting).