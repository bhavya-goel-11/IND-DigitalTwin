# OSM Data Directory

This directory contains OpenStreetMap (OSM) data files used as input for road network geometry.

## Current Files

### [`sample_map.osm`](./sample_map.osm)
Sample OSM extract for demonstration purposes. Contains a small Delhi junction area with:
- Multiple road types (highway=primary, secondary, residential)
- Junction intersections
- Basic road network topology

## Adding Your Own OSM Data

### Step 1: Obtain OSM Data
Get OSM data for your area of interest:

**Option A: Export from OpenStreetMap.org**
1. Go to [openstreetmap.org](https://www.openstreetmap.org)
2. Navigate to your area of interest
3. Click "Export" in the top menu
4. Select a small area (few hundred meters) by dragging the map
5. Click "Export" button to download `.osm` file

**Option B: Use Overpass API/JOSM**
- For more control over data selection
- Better for larger areas or specific feature filtering

### Step 2: Place in Directory
1. Save your OSM file in this directory: `data/osm/`
2. Use a descriptive filename (e.g., `my_junction.osm`, `delhi_area_2024.osv`)

### Step 3: Update Configuration
Edit your configuration file to point to the new OSM file:
```json
{
  "geometry": {
    "source": "osm",
    "osmFile": "data/osm/my_junction.osm"  // Update this path
  }
}
```

## OSM File Requirements

**What the toolkit needs**:
- Valid XML format (not compressed .osm.pbf or .osm.bz2)
- Contains `<node>` elements with lat/lon coordinates
- Contains `<way>` elements with highway tags
- Geographic extent should be small (< 1km²) for projection accuracy

**What gets extracted**:
- Road centerlines from highway-tagged ways
- Node coordinates and connectivity
- Road classification (primary, secondary, residential, etc.)

**Current limitations**:
- No lane count inference
- No elevation data usage
- No turn restrictions
- No traffic signal locations

## Troubleshooting OSM Data

**"No nodes parsed" error**:
- Check file is valid XML (open in text editor)
- Ensure file is not compressed
- Verify nodes have `lat` and `lon` attributes

**"Very skewed geometry"**:
- Area may be too large (try smaller geographic extent)
- Consider areas with latitude span < 0.01 degrees

**"Missing roads"**:
- Ways may lack `highway` tags
- Ways may have insufficient nodes (< 2 valid nodes)
- Check OSM data includes road network (not just buildings/amenities)

## File Size Guidelines

- **Recommended**: 1-50 KB (small junction/area)
- **Maximum practical**: 500 KB (larger network)
- **Avoid**: > 1 MB files (projection issues, slow processing)

For large areas, consider splitting into multiple smaller OSM files and processing separately.

## Related Documentation

- Main workflow: [../../README.md](../../README.md#using--swapping-an-osm-file)
- Configuration: [../../configs/README.md](../../configs/README.md)
- Sample map notes: [../../docs/sample_map_notes.md](../../docs/sample_map_notes.md)