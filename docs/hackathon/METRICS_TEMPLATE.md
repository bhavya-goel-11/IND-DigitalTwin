# Metrics Capture Template
Fill this after running the demo script.

## Run Context
- Date:
- MATLAB Version:
- Machine Specs:

## Scenario Config
- Config ID:
- Variation Count:
- Seed:

## Core Metrics
| Metric | Value | Notes |
|--------|-------|-------|
| Generation time (s) |  | tic/toc around generateScenarioFromConfig |
| Total vehicles |  | From metrics.totalVehicles |
| Vehicle mix (car) |  | count |
| Vehicle mix (twoWheeler) |  | count |
| Vehicle mix (threeWheeler) |  | count |
| pothole features |  | sum counts |
| barricadeCluster features |  | sum counts |
| parkedRickshawRow features |  | sum counts |
| Additional feature (waterPatch) |  | if added |
| Variants generated |  | size(results) |

## Variant Spread (Example)
| Variant | Vehicles | Potholes | Barricades | Rickshaws |
|---------|----------|----------|-----------|-----------|
| 1 |  |  |  |  |
| 2 |  |  |  |  |
| 3 |  |  |  |  |

## Observations / Talking Points
- 
- 
- 

## Future KPI Ideas
- Average approach speed delta (with vs without barricade)
- Headway distribution variance
- Queue length proxy (vehicles within X m of center)
