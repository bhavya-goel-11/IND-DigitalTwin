# Demo Guide
This guide lists the exact steps and screenshot targets to showcase the toolkit during the hackathon.

## Environment Prep
1. Open MATLAB (R2025b+ with Automated Driving Toolbox).
2. Ensure repository root is current folder.
3. Run: `addpath(genpath(fullfile(pwd,'src','matlab')));`

## Step 1: Show Config Intent
- Open `configs/examples/delhi_sample_canonical.json`.
- Highlight microFeatures, behaviorProfiles, variation.
- Screenshot 1: JSON open in editor with annotations.

## Step 2: Generate Scenario
```matlab
out = generateScenarioFromConfig('configs/examples/delhi_sample_canonical.json');
```
- Screenshot 2: MATLAB Command Window showing completion & notes.

## Step 3: Visualize Scenario
```matlab
plot(out.scenario);
```
- Screenshot 3: Scenario plot (roads & initial vehicle positions).

## Step 4: Inspect Feature Placement
```matlab
out.features
```
- Screenshot 4: Printed struct array with types, counts, positions.

## Step 5: Metrics Collection
```matlab
m = collectMetrics(out);
disp(m.featureCounts);
disp(m.vehicleClassCounts);
```
- Screenshot 5: Metrics output (featureCounts & vehicleClassCounts).

## Step 6: Generate Variations
```matlab
variants = generateScenarioSet('configs/examples/delhi_sample_canonical.json');
arrayfun(@(i) collectMetrics(variants{i}), 1:numel(variants), 'UniformOutput', false);
```
- Screenshot 6: Display variation metrics differences (counts vary subtly).

## Step 7: Add New Micro-Feature (Live)
1. Duplicate a JSON in `assets/indian/microfeatures/` as `waterPatch.json` (example):
```json
{
  "id": "waterPatch",
  "category": "surface",
  "description": "Localized waterlogging reducing speed and causing lateral avoidance.",
  "footprint": {"shape": "ellipse", "a": 1.2, "b": 0.8},
  "speedImpact": {"reductionMean": 3.0, "reductionStd": 0.7},
  "persistence": "temporary"
}
```
2. Add entry to config microFeatures array: `{ "type": "waterPatch", "count": 2, "placementRule": "nearStopLine", "intensity": 0.5 }`.
3. Regenerate scenario and re-run metrics.
- Screenshot 7: New feature counts including waterPatch.

## Optional Stretch (If Time)
- Show OSM stub usage by modifying config geometry.source to `"osm"` and setting `"osmFile"`.
- Clarify stub vs full implementation plan.

## Final Slide Assets
- Slide 1: Problem (photos or bullet list) + One-liner
- Slide 2: Architecture Diagram (Config → Generation → Augmentation → Metrics)
- Slide 3: Feature Library Table (3–5 entries)
- Slide 4: Demo Timeline Screenshots (1–3 condensed)
- Slide 5: Metrics Snapshot (table with counts)
- Slide 6: Roadmap & Impact

## Metrics Template (Populate After Run)
| Metric | Value |
|--------|-------|
| Scenario generation time (s) | <fill> |
| Vehicle total | <fill> |
| Feature count (pothole) | <fill> |
| Feature count (barricadeCluster) | <fill> |
| Feature count (parkedRickshawRow) | <fill> |
| Variants generated | <fill> |

## Talking Points Cheat Sheet
- Config = declarative intent; code = reusable engine.
- Assets are pluggable JSON; no code change needed to extend catalog.
- Variation enables sensitivity & robustness studies.
- Roadmap adds realism: speed perturbations, OSM parsing, NL interface.

## Timing (Target 3–4 min)
- 30s Problem + One-liner
- 60s Architecture + Config
- 60s Live commands (gen, metrics, variation)
- 30s New asset add
- 30–40s Roadmap + Ask

---
End of guide.
