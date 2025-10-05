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
1. Config-driven geometry + augmentation pipeline
2. Indian micro-feature asset library (potholes, barricades, parked rickshaws)
3. Behavior profile scaffolding extending IDM/Gipps concepts
4. Variation generation & metrics (incrementally expanding)

Current Status (Iteration 2)
---------------------------
Implemented scaffold featuring:
- Config schema (`configs/schema.json`)
- Example config (`configs/examples/delhi_sample_canonical.json`)
- Micro-feature metadata (pothole, barricade cluster, parked rickshaw row)
- Geometry-aware heuristic placement (`augmentScenario.m`)
- Scenario generation pipeline: `generateScenarioFromConfig.m`
- Behavior profile tagging: `applyBehaviorProfiles.m`
- Multi-class Poisson traffic spawning: `spawnTraffic.m`
- Variation generation: `generateScenarioSet.m`
- Metrics collection: `collectMetrics.m`
- Visualization helper: `plotAppliedFeatures.m`
- Report & packaging scripts: `exportScenarioReport.m`, `prepareHackathonPackage.m`
- Demo script: `IND_DigitalTwin_Demo.m`

Repository Layout
-----------------
```
configs/                JSON schemas & example scenario configs
assets/indian/          Micro-feature metadata definitions
src/matlab/             Core MATLAB generation & helper scripts
opentraffic/            OpenTrafficLab upstream code (behavior models)
data/osm/               OSM source files (sample)
docs/hackathon/         Pitch, demo guide, metrics template
```

Quick Start
-----------
In MATLAB (R2025b+ with Automated Driving Toolbox):
```matlab
% One-click demo (from repo root):
run_ind_digitaltwin_demo
```

This will:
- Add all required paths
- Generate the sample scenario from config
- Plot the scenario and feature overlays
- Display feature and vehicle metrics
- Generate scenario variations
- Package all reports and artifacts in `dist/`

Artifacts appear under `dist/` (reports, feature plot, summary JSON).

Config Anatomy (Excerpt)
------------------------
```json
{
	"geometry": {"source": "canonicalTemplate", "canonicalTemplate": "canonical_junction"},
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
			| Geometry Builder      | (Canonical / OSM stub)
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
TBD (Choose a permissive license; OpenTrafficLab components retain original licenses in their directory.)

Credits
-------
Base traffic behavior components adapted from MathWorks OpenTrafficLab.
Hackathon scaffold authored for rapid experimentation.

Contact / Follow-Up
-------------------
For extending to production-grade ingestion, driver calibration, or NL integration, open an issue or outline a mini design in `docs/`.

