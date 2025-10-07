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
configs/                JSON schemas & example scenario configs
assets/indian/          Micro-feature metadata definitions
src/matlab/             Core MATLAB generation & helper scripts
<!-- Removed: opentraffic/ directory -->
data/osm/               OSM source files (sample)
docs/hackathon/         Pitch, demo guide, metrics template
```

Quick Start
-----------
In MATLAB (R2025b+ with Automated Driving Toolbox):
```matlab
% One-click demo (from repo root) – now uses OSM based config by default:
run_ind_digitaltwin_demo
```

This will:
- Add all required paths
- Generate the OSM-based sample scenario (`delhi_osm_demo.json`)
- Place micro-features (potholes, barricades, parked rickshaw rows)
- Plot the scenario and feature overlays
- Spawn multi-class traffic with behavior profiles
- Display feature and vehicle metrics
- Generate scenario variations
- Package all reports and artifacts in `dist/`

Artifacts appear under `dist/` (reports, feature plot, summary JSON).

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

Adding a New Micro-Feature
--------------------------
1. Create JSON in `assets/indian/microfeatures/` (e.g. `waterPatch.json`).
2. Reference it in config under `microFeatures` with a `placementRule`.
3. Run `run_ind_digitaltwin_demo` again—no code modification required unless special logic needed.

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

Using & Swapping an OSM File
----------------------------
The toolkit now includes a lightweight OSM importer (`buildScenarioFromOSM.m`) that:
- Parses nodes and highway-tagged ways
- Projects lat/lon to a local XY plane (equirectangular approximation)
- Creates simple 2‑lane roads for each highway way
- Returns OSM metadata as `out.osmMeta` (no direct modification of scenario object)

What it does NOT yet do:
- Lane count inference / widths per classification
- Junction synthesis or conflict zone extraction
- Turn restrictions, speed limits, elevation
- Oneway enforcement (data stored but not acted on)

To use a different OSM file:
1. Place your file in `data/osm/` (e.g. `data/osm/my_area.osm`). Keep it geographically small (few hundred meters) for projection accuracy.
2. Duplicate `configs/examples/delhi_osm_demo.json` and change only:
	- `geometry.osmFile`
	- (Optionally) micro-feature counts / placement rules
	- (Optionally) arrival stream rates / class mix
3. Run:
	```matlab
	run_ind_digitaltwin_demo  % (after updating the config path inside if needed)
	```
4. Or programmatically:
	```matlab
	out = generateScenarioFromConfig('configs/examples/my_area_osm.json');
	plot(out.scenario); plotAppliedFeatures(out.scenario, out.features);
	```
5. Iterate by editing the JSON and re-running.

Introspect OSM metadata:
```matlab
meta = out.osmMeta;
disp(meta.roadCreatedCount);
``` 

If roads look sparsely segmented: OSM ways may contain very few nodes; consider exporting with higher waypoint density or manually densifying.

Troubleshooting:
- Error 'No nodes parsed': File may be compressed or truncated—ensure raw .osm XML.
- Very skewed geometry: Large lat span (> ~0.01 deg) – switch to a proper projection (future enhancement).
- Missing roads: Way lacked a <tag k="highway" ...> or had fewer than two valid nodes.

Next OSM Enhancements (planned): lane count by classification, speed limits, oneway handling, junction graph extraction, centerline smoothing.

