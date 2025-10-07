IND-DigitalTwin: Accelerated Indian Urban Junction Digital Twin Toolkit
======================================================================

Hackathon Pitch (Concise)
------------------------
One-liner: Config + augmentation toolkit that injects Indian junction realism (potholes, barricades, informal lane usage, multi-class swarms) into MATLAB driving scenarios in minutes.

Why it matters: Existing tools assume pristine geometry and disciplined behavior; this accelerates realistic scenario authoring for congestion & incident simulations.

Differentiators:
- Declarative JSON intent → reproducible scenarios
- Pluggable micro-feature asset library
- Variation generation with seeding
- Extensible behavior profiling

See full pitch: `docs/hackathon/PITCH.md`

Objective
---------
Accelerate creation of realistic digital twins of Indian urban junctions (Delhi focus) using MATLAB & Automated Driving Toolbox by layering:
1. OSM-based geometry import with road classification
2. Indian micro-feature asset library (potholes, barricades, parked rickshaws)
3. Behavior profile scaffolding extending IDM/Gipps concepts
4. Variation generation & metrics (incrementally expanding)

Current Status (Iteration 2)
---------------------------
Implemented scaffold featuring:
- Config schema (`configs/schema.json`)
- Example config (`configs/examples/delhi_osm_demo.json`)
- Micro-feature metadata (pothole, barricade cluster, parked rickshaw row)
- Geometry-aware heuristic placement (`augmentScenario.m`)
- Scenario generation pipeline: `generateScenarioFromConfig.m`
- Behavior profile tagging: `applyBehaviorProfiles.m`
- Multi-class Poisson traffic spawning: `spawnTraffic.m`
- Variation generation: `generateScenarioSet.m`
- Metrics collection: `collectMetrics.m`
- Visualization helper: `plotAppliedFeatures.m`
- Report & packaging scripts: `exportScenarioReport.m`, `prepareHackathonPackage.m`
- Demo script: `run_ind_digitaltwin_demo.m`

Repository Layout
-----------------
```
├── configs/                    # JSON schemas & example scenario configs
│   ├── examples/              # Ready-to-use configuration files
│   └── schema.json           # Validation schema
├── data/                      # Input data files
│   └── osm/                  # OpenStreetMap data files
├── src/                       # Source code
│   ├── assets/               # Asset library (metadata & 3D models)
│   └── matlab/               # Core MATLAB functions
├── docs/                      # Documentation
├── dist/                      # Generated outputs (reports, plots)
└── run_ind_digitaltwin_demo.m # One-click demo script
```

**📁 Key Directories:**
- **[`configs/`](./configs/)**: Configuration files and schema
- **[`data/osm/`](./data/osm/)**: Place your OSM files here  
- **[`src/assets/`](./src/assets/)**: Indian micro-feature library
- **[`src/matlab/`](./src/matlab/)**: Core generation functions

## 🚀 Quick Start

**Prerequisites**: MATLAB R2025b+ with Automated Driving Toolbox

### Option 1: MATLAB Command Window
```matlab
% From project root directory
run_ind_digitaltwin_demo
```

### Option 2: Windows PowerShell
```powershell
cd "C:\path\to\your\IND-DigitalTwin"
matlab -batch "run_ind_digitaltwin_demo"
```

### Option 3: Your Own OSM Data
```powershell
# 1. Copy your OSM file
copy "your_map.osm" "data\osm\your_map.osm"

# 2. Update config file (edit configs/examples/delhi_osm_demo.json):
#    "osmFile": "data/osm/your_map.osm"

# 3. Run visualization  
matlab -batch "addpath('src/matlab'); out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json'); plot(out.scenario); plotAppliedFeatures(out.scenario, out.features);"
```

**Result**: Interactive MATLAB figure showing your road network with Indian micro-features overlaid

Both options will:
- Generate road network from sample OSM data
- Place Indian micro-features (potholes, barricades, parked vehicles)
- **Plot interactive road network with overlaid features**
- Spawn realistic multi-class traffic
- Display comprehensive metrics
- Save all outputs to [`dist/`](./dist/) directory

## Using Your Own OSM Data

### Step 1: Get OSM Data
1. Go to [openstreetmap.org](https://www.openstreetmap.org)
2. Navigate to your area of interest (keep it small - few hundred meters)
3. Click **"Export"** → Select area → **"Export"** button
4. Save the `.osm` file

### Step 2: Place OSM File
```powershell
# Copy your OSM file to the data directory
copy "your_area.osm" "data\osm\your_area.osm"
```

### Step 3: Update Configuration
Edit [`configs/examples/delhi_osm_demo.json`](./configs/examples/delhi_osm_demo.json):
```json
{
  "geometry": {
    "source": "osm",
    "osmFile": "data/osm/your_area.osm"
  }
}
```

### Step 4: Generate and Plot Your Scenario
```matlab
% In MATLAB
addpath('src/matlab');
out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');

% Plot road network
plot(out.scenario);

% Plot features overlaid on roads
plotAppliedFeatures(out.scenario, out.features);
```

### Complete Command Sequence
```powershell
# Windows PowerShell - Complete workflow
cd "C:\path\to\your\IND-DigitalTwin"
copy "C:\path\to\your_map.osm" "data\osm\your_map.osm"
matlab -batch "addpath('src/matlab'); out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json'); plot(out.scenario); plotAppliedFeatures(out.scenario, out.features);"
```

**Result**: Interactive MATLAB figure showing your road network with Indian micro-features (color-coded by type) overlaid at realistic positions.

## Adding Features at Specific Coordinates

### Quick Example: Place Pothole at Exact Location
```matlab
% Load scenario and place feature at coordinates (25.5, 10.2)
addpath('src/matlab');
out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');
feature = placeFeatureAtCoordinate(out.scenario, 'pothole', 25.5, 10.2);

% Visualize
plot(out.scenario); hold on;
scatter(feature.featureCoords(:,1), feature.featureCoords(:,2), 120, 'r', 'filled');
```

### Interactive Coordinate Selection
```matlab
% Click on plot to select coordinates visually
coords = selectCoordinatesInteractively(out.scenario);
feature = placeFeatureAtCoordinate(out.scenario, 'pothole', coords(:,1), coords(:,2));
```

### Complete Demo
```matlab
% Run comprehensive coordinate placement demo
demo_coordinate_placement
```

📋 **For detailed coordinate placement guide**: [`docs/COORDINATE_PLACEMENT_GUIDE.md`](./docs/COORDINATE_PLACEMENT_GUIDE.md)

Config Anatomy (Excerpt)
------------------------
```json
{
	"geometry": {"source": "osm", "osmFile": "data/osm/your_area.osm"},
	"microFeatures": [
		{"type": "pothole", "count": 6, "placementRule": "nearStopLine"},
		{"type": "barricadeCluster", "count": 1, "placementRule": "approachNorth"},
		{"type": "parkedRickshawRow", "count": 2, "placementRule": "shoulderEast"}
	],
	"behaviorProfiles": [
		{"id": "car_default", "vehicleClass": "car", "aggression": 0.5},
		{"id": "twoWheeler_swarm", "vehicleClass": "twoWheeler", "aggression": 0.7},
		{"id": "threeWheeler_auto", "vehicleClass": "threeWheeler", "aggression": 0.55}
	],
	"trafficDemand": {
		"timeHorizon": 300,
		"arrivalStreams": [
			{"entryId": "west_in", "ratePerHour": 800, "vehicleClassMix": {"car": 0.4, "twoWheeler": 0.4, "threeWheeler": 0.2}},
			{"entryId": "south_in", "ratePerHour": 600, "vehicleClassMix": {"car": 0.5, "twoWheeler": 0.3, "threeWheeler": 0.2}},
			{"entryId": "east_in", "ratePerHour": 500, "vehicleClassMix": {"car": 0.35, "twoWheeler": 0.5, "threeWheeler": 0.15}}
		]
	},
	"variation": {"count": 3, "seed": 42},
	"export": {"matScenario": true, "report": true}
}
```

Available Micro-Features
------------------------
The toolkit includes comprehensive Indian urban micro-features:

**Obstructions**: `pothole`, `barricadeCluster`, `parkedVehicleRow`, `parkedRickshawRow`
**Infrastructure**: `streetVendorStall`, `temporaryMarket` 
**Activity**: `peakHourEncroachment`, `cattleObstruction`

Each feature has realistic placement rules, visual properties, and behavioral impact on traffic flow. See [`src/assets/README.md`](./src/assets/README.md) for complete feature descriptions.

Architecture Overview
---------------------
```
				+------------------+
				|  Config (JSON)   |
				+---------+--------+
									|
									v
			+-----------------------+
			| Geometry Builder      | (OSM Parser)
			+-----------+-----------+
									|
									v
			+-----------------------+
			| Augmentation Engine   | (Micro-features placement)
			+-----------+-----------+
									|
									v
			+-----------------------+
			| Traffic Spawner       | (Multi-class Poisson)
			+-----------+-----------+
									|
									v
			+-----------------------+
			| Behavior Tagger       |
			+-----------+-----------+
									|
									v
			+-----------------------+
			| Metrics & Packaging   |
			+-----------------------+
```

Limitations & Open Areas
------------------------
- OSM ingestion is a stub (no lane reconstruction yet)
- Feature placement heuristic (not lane-shape precise)
- Behavior parameters not yet integrated into dynamic longitudinal models
- Metrics limited to counts (no speed / headway / queue KPIs)
- No natural-language config parser (planned)

Hackathon Documentation
-----------------------
Behavior Profiles (Optional Fields & Defaults)
---------------------------------------------
Behavior profile objects in config can be minimal. Only `id` and `vehicleClass` are strictly required.
If omitted, the system supplies:
```
aggression        -> 0.5
headwayFactor     -> 1.0
lateralDrift      -> 0
desiredSpeedMean  -> 14   % m/s (~50 km/h)
desiredSpeedStd   -> 2    % m/s
```
Example minimal entry:
```json
{ "id": "car_basic", "vehicleClass": "car" }
```
Full entry:
```json
{
	"id": "twoWheeler_swarm",
	"vehicleClass": "twoWheeler",
	"aggression": 0.7,
	"desiredSpeedMean": 16,
	"desiredSpeedStd": 2.5
}
```
All unspecified fields inherit defaults. This keeps configs concise while allowing targeted overrides.
- Pitch: `docs/hackathon/PITCH.md`
- Demo Guide (screenshots & flow): `docs/hackathon/DEMO_GUIDE.md`
- Metrics Template: `docs/hackathon/METRICS_TEMPLATE.md`

Roadmap
-------
| Phase | Item | Outcome |
|-------|------|---------|
| 3 | Full OSM parsing | Real road geometry fidelity |
| 3 | Dynamic speed/headway modifiers | Congestion realism |
| 4 | Natural language → config | Non-technical authoring |
| 4 | Enhanced metric suite | Validation & calibration |
| 5 | Parallel batch generation | Large-scale scenario sweeps |
| 5 | Report visualizations | Stakeholder communication |

Contribution Guidelines (Lightweight)
------------------------------------
1. Add new assets via JSON, avoid hard-coding.
2. Keep config schema stable; propose changes via PR note.
3. Document new metrics or placement rules in code comments.

License
-------
TBD (Choose a permissive license for the digital twin system.)

Credits
-------
Digital twin system with OSM-based road network import and feature placement.
Hackathon scaffold authored for rapid experimentation.

Contact / Follow-Up
-------------------
For extending to production-grade ingestion, driver calibration, or NL integration, open an issue or outline a mini design in `docs/`.

## Troubleshooting OSM Data

**"No nodes parsed" error:**
- Check file is valid XML (not compressed .osm.pbf or .osm.bz2)
- Ensure file contains `<node>` elements with `lat` and `lon` attributes

**"Very skewed geometry":**
- Area may be too large (keep geographic extent small - few hundred meters)
- Try latitude span < 0.01 degrees for best projection accuracy

**"Missing roads":**
- OSM ways may lack `highway` tags or have insufficient nodes
- Verify your area includes road network data (not just buildings)

**Roads look sparse:**
- OSM ways may have few intermediate nodes
- Consider exporting with higher waypoint density from OSM

For detailed OSM usage instructions, see [`data/osm/README.md`](./data/osm/README.md).

## Documentation

📚 **Complete Documentation:**
- **[Configuration Guide](./configs/README.md)**: JSON schema and examples  
- **[OSM Data Guide](./data/osm/README.md)**: Detailed OSM usage and troubleshooting
- **[Asset Library](./src/assets/README.md)**: Feature definitions and 3D models
- **[MATLAB Functions](./src/matlab/README.md)**: Complete API reference
- **[Project Documentation](./docs/README.md)**: Additional guides and notes

## System Requirements

- **MATLAB R2025b** or later
- **Automated Driving Toolbox**
- **Windows/Mac/Linux** (commands shown for Windows)

## License

TBD (Choose a permissive license for the digital twin system.)

## Credits

Digital twin system with OSM-based road network import and realistic Indian urban feature placement.

---

**Next OSM Enhancements (planned)**: Lane count inference, speed limits, oneway handling, junction extraction, centerline smoothing.

