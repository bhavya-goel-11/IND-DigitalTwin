# 🖱️ Interactive Feature Placement - Quick Guide

## ✅ Problem Solved!
The `augmentScenario` function error has been **fixed**. All functions are now properly accessible.

## 🚀 Interactive Method: Step-by-Step

### Step 1: Open MATLAB and Setup
```matlab
% In MATLAB Command Window
setup_ind_digitaltwin_paths();
```

### Step 2: Load Your Scenario  
```matlab
% Load OSM-based scenario
out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');
```

### Step 3: Start Interactive Coordinate Selection
```matlab
% This opens a plot window for interactive clicking
coords = selectCoordinatesInteractively(out.scenario);
```

**What happens:**
- 📊 Plot window opens showing your road network
- 🖱️ Click anywhere to select coordinates
- 🔴 Red numbered dots appear where you click
- ⌨️ Press **Enter** (without clicking) when done
- 💾 Coordinates automatically saved

### Step 4: Place Features at Selected Coordinates
```matlab
% Place potholes at all selected coordinates
feature = placeFeatureAtCoordinate(out.scenario, 'pothole', coords(:,1), coords(:,2));
```

### Step 5: Visualize Results
```matlab
% Show the results
figure;
plot(out.scenario); hold on;
scatter(feature.featureCoords(:,1), feature.featureCoords(:,2), 150, 'r', 'filled');
title('Interactive Feature Placement Results');
legend('Roads', 'Potholes', 'Location', 'best');
hold off;
```

## 🎯 One-Command Interactive Session

For the complete interactive workflow in one go:

```matlab
setup_ind_digitaltwin_paths();
out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json');
coords = selectCoordinatesInteractively(out.scenario);
if ~isempty(coords)
    feature = placeFeatureAtCoordinate(out.scenario, 'pothole', coords(:,1), coords(:,2));
    figure; plot(out.scenario); hold on;
    scatter(feature.featureCoords(:,1), feature.featureCoords(:,2), 150, 'r', 'filled');
    title('Interactive Feature Placement'); legend('Roads', 'Potholes');
    fprintf('✅ Successfully placed %d features!\n', size(coords,1));
end
```

## 🛠️ Available Feature Types

Replace `'pothole'` with any of these:
- `'pothole'` - Road surface damage
- `'barricadeCluster'` - Construction barriers
- `'parkedVehicleRow'` - Parked cars
- `'parkedRickshawRow'` - Auto-rickshaw parking
- `'streetVendorStall'` - Street vendor setup
- `'temporaryMarket'` - Market stalls
- `'peakHourEncroachment'` - Rush hour obstacles
- `'cattleObstruction'` - Livestock on roads

## 💡 Pro Tips

1. **Zoom first**: Use MATLAB's zoom tool before clicking for precision
2. **Multiple runs**: Run interactive selection multiple times for different feature types
3. **Check coordinates**: Coordinates are saved as `selectedCoordinates` in workspace
4. **Visual feedback**: Each click shows a numbered red dot immediately
5. **Cancel**: Close the figure window to cancel selection

## 🎬 PowerShell One-Liner (Advanced)

For Windows PowerShell users:
```powershell
matlab -batch "setup_ind_digitaltwin_paths(); out = generateScenarioFromConfig('configs/examples/delhi_osm_demo.json'); fprintf('Scenario loaded. Ready for interactive selection.\n'); fprintf('In MATLAB GUI: coords = selectCoordinatesInteractively(out.scenario)\n');"
```

Then continue in MATLAB GUI for the interactive part.

## ✅ Verification

To verify everything is working:
1. ✓ `setup_ind_digitaltwin_paths()` runs without errors
2. ✓ All functions show checkmarks (✓)
3. ✓ Scenario loads with road count displayed
4. ✓ Interactive window opens when you call `selectCoordinatesInteractively()`

**You're all set!** The interactive method now works perfectly for placing features at exact coordinates of your choice.