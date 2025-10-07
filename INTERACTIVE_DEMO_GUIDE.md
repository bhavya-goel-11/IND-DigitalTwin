# 🎯 Interactive Feature Placement Demo Guide

## 🚀 Quick Start

Simply run:
```matlab
run_ind_digitaltwin_demo
```

## 📋 What Happens Step-by-Step

### 1️⃣ **Map Loading**
- OSM road network loads and displays
- You'll see coordinate bounds and road count
- Clean map ready for feature placement

### 2️⃣ **Feature Selection Menu**
You'll see 8 available feature types:
```
1. pothole - Road surface damage/potholes
2. barricadeCluster - Construction barriers and roadblocks  
3. parkedVehicleRow - Row of parked cars
4. parkedRickshawRow - Auto-rickshaw parking area
5. streetVendorStall - Street vendor setup
6. temporaryMarket - Temporary market stalls
7. peakHourEncroachment - Rush hour space usage
8. cattleObstruction - Livestock on roadway
```

### 3️⃣ **Interactive Coordinate Selection**
1. **Choose feature type** (enter number 1-8)
2. **Click on map** to select coordinates
   - Red numbered dots appear where you click
   - Click multiple times for multiple instances
3. **Press Enter** when done selecting coordinates
4. **Features appear immediately** on the map with color coding

### 4️⃣ **Multiple Sessions**
- After placing one feature type, you're asked: "Add more features?"
- Enter "y" to add different feature types
- Each type gets its own color and labels

### 5️⃣ **Final Results**
- **Enhanced visualization** with legend showing all feature types
- **Auto-saved files** in `dist/` directory:
  - `interactive_scenario.mat` - Complete scenario data
  - `interactive_scenario_plot.png` - Final visualization
  - `interactive_scenario_report.txt` - Detailed summary
- **Workspace variable** `interactiveScenario` for further analysis

## 🎨 Visual Features

- **Color-coded features**: Each feature type has a unique color
- **Real-time updates**: See features appear as you place them
- **Smart labeling**: Features are labeled with type abbreviations
- **Professional plots**: Grid, axis labels, legends, titles
- **Coordinate display**: Exact coordinates shown in reports

## 💡 Pro Tips

1. **Start with roads**: Look at the road layout before placing features
2. **Strategic placement**: Click near intersections, curves, or chokepoints for realism
3. **Multiple types**: Mix different feature types for realistic scenarios
4. **Zoom in**: Use MATLAB's zoom tool for precise placement
5. **Check dist/**: All your work is automatically saved

## 🎯 Example Workflow

```
1. Run: run_ind_digitaltwin_demo
2. Map loads showing road network
3. Choose: 1 (pothole)
4. Click 3-4 locations on roads
5. Press Enter
6. Choose: y (add more)
7. Choose: 2 (barricadeCluster) 
8. Click 1-2 locations
9. Press Enter
10. Choose: n (finish)
11. Final enhanced plot appears
12. Check dist/ folder for saved files
```

## 📁 Output Files

After completion, check `dist/` directory for:
- **Scenario file**: Complete MATLAB scenario object
- **Plot image**: High-quality PNG of your custom scenario  
- **Text report**: Detailed coordinates and summary
- **Workspace data**: Available as `interactiveScenario` variable

## 🔧 Troubleshooting

**Map doesn't appear**: 
- Ensure you're running from project root directory
- Check that `data/osm/sample_map.osm` exists

**Click selection not working**:
- Make sure the plot window has focus
- Try clicking directly on road lines
- Use MATLAB's zoom tool if needed

**Want to restart**:
- Close all figure windows
- Run `run_ind_digitaltwin_demo` again

## 🎉 Result

You'll have a completely customized Indian urban scenario with features placed exactly where you want them, ready for traffic simulation and analysis!