# A1 Heuristic Baseline Mission

## Overview

This is the **Phase 0** implementation of the 3-AUV cooperative target tracking mission with heuristic baseline behaviors.

### Mission Parameters (Phase 0)

- **Location**: Monterey Bay, CA (36.8°N, 121.9°W)
- **Vehicle Type**: REMUS 100 (1.6m length, 37kg mass, 2.5 m/s max speed)
- **Depth**: Fixed at 50m (2D tracking)
- **Sensors**: Perfect bearing-only detections (no noise)
- **Communications**: Perfect (no packet loss, unlimited range)
- **Team Size**: 3 AUVs + 1 Target

### Vehicle Roles

1. **AUV 0 (auv_0)** - Pinger Role
   - Color: Blue
   - Start: (0, -50) at heading 0°
   - Strategy: Pursue from directly behind target

2. **AUV 1 (auv_1)** - Left Shadower
   - Color: Cyan
   - Start: (-60, -80) at heading 90°
   - Strategy: Track from left flank

3. **AUV 2 (auv_2)** - Right Shadower
   - Color: Green
   - Start: (60, -80) at heading 90°
   - Strategy: Track from right flank

4. **Target**
   - Color: Red
   - Start: (0, 0) at heading 0°
   - Speed: 1.5 m/s (matches AUVs)
   - Pattern: Straight line, then patrol, then evasive

## Quick Start

### 1. Test Configuration Generation

```bash
./launch.sh --just_make
```

This generates the `targ_*.moos` and `targ_*.bhv` files without launching.

### 2. Launch Mission

```bash
./launch.sh
```

Or with time warp:

```bash
./launch.sh --warp=4  # 4x real-time
./launch.sh 10        # 10x real-time
```

### 3. Operate Mission

In pMarineViewer:
1. Click **DEPLOY** - All vehicles start moving
2. Click **TRACK** - AUVs begin tracking behaviors
3. Watch the formation track the target
4. Click **STATION** - AUVs hold position (pause)
5. Click **RETURN** - AUVs return to start

### 4. Stop Mission

Press `CTRL-C` in the terminal running `./launch.sh`

### 5. Clean Up

```bash
./clean.sh
```

Removes all generated files and logs.

## File Structure

```
a1_heuristic_baseline/
├── meta_vehicle.moos       # Vehicle template
├── meta_vehicle.bhv        # Behavior template (AUVs)
├── meta_target.bhv         # Target behavior
├── meta_shoreside.moos     # Shoreside (GUI + sensors)
├── plug_auv_0.moos         # AUV 0 config
├── plug_auv_1.moos         # AUV 1 config
├── plug_auv_2.moos         # AUV 2 config
├── plug_target.moos        # Target config
├── launch.sh               # Launch script
├── clean.sh                # Cleanup script
└── README.md               # This file
```

## Expected Behavior

### Phase 1: Deployment (0-30s)
- AUVs move from starting positions toward search area
- Target begins straight-line transit (0,0) → (600,0)

### Phase 2: Detection & Tracking (30s+)
- AUVs detect target via `uFldContactRangeSensor` (bearing-only)
- AUV 0 (pinger) pursues from behind
- AUV 1/2 (shadowers) take flank positions
- Formation maintains ~100m distance

### Phase 3: Target Pattern Change (300s)
- Target switches to patrol pattern
- AUVs adjust to maintain formation

### Phase 4: Evasive Maneuver (600s)
- Target increases speed to 2.0 m/s
- Target performs evasive zigzag
- Tests formation resilience

## Data Logging

Logs are saved to `logs/` directory:

```bash
logs/
├── LOG_auv_0_YYYYMMDD_HHMMSS.alog
├── LOG_auv_1_YYYYMMDD_HHMMSS.alog
├── LOG_auv_2_YYYYMMDD_HHMMSS.alog
├── LOG_target_YYYYMMDD_HHMMSS.alog
└── LOG_shoreside_YYYYMMDD_HHMMSS.alog
```

### Analyze Logs

```bash
# View log in GUI
alogview logs/LOG_auv_0_*.alog

# Extract specific variable
aloggrep NAV_X logs/LOG_auv_0_*.alog

# Check contact detections
aloggrep CONTACT_INFO logs/LOG_auv_0_*.alog

# View helm behavior status
aloggrep IVPHELM_SUMMARY logs/LOG_auv_0_*.alog
```

## Performance Metrics

Phase 0 targets (perfect conditions):
- **RMSE**: 45-55m (triangulation accuracy)
- **Time-in-Track**: >90% (contact maintained)
- **Collisions**: 0 (safety behaviors active)
- **Formation**: Fixed (pinger + 2 shadowers)

## Troubleshooting

### Issue: No GUI appears
**Solution**: Check X11 display
```bash
echo $DISPLAY  # Should show :0 or :1
xdpyinfo       # Verify X server running
```

### Issue: Vehicles don't move after DEPLOY
**Check**: uMAC console for errors
```bash
# In uMAC, check these variables:
DEPLOY_ALL     # Should be "true"
IVPHELM_STATE  # Should show behaviors running
```

### Issue: No contact detections
**Check**: Vehicle-target distance
```bash
# In pMarineViewer, measure distance
# Should be < 500m for detection (Phase 0 range)
```

### Issue: Behaviors not activating
**Check**: Behavior conditions in `targ_*.bhv` files
```bash
# Ensure DEPLOY=true, TRACKING=true
# Check role assignments match plug files
```

## Next Steps

### Phase 0.5 (Week 2): Add Sensor Noise
- Bearing noise: 5° std dev
- Detection probability: P_d = 0.9
- False alarm rate: P_fa = 0.01

### Phase 1 (Week 3): Realistic Communications
- Gilbert-Elliott packet loss (~50%)
- Range-dependent success rate

### Phase 1.5 (Weeks 4-5): Full Acoustics
- BELLHOP transmission loss
- Sound speed profiles
- Bathymetry effects

### Phase 2 (Week 6): 3D Tracking
- Variable depth (30-70m)
- Evasive target behaviors
- Randomized initial conditions

### Phase 3 (Weeks 7-9): MARL Integration
- PettingZoo wrapper
- MATSMI memory
- MATD3 training

## Documentation

- **Full Implementation**: `obsidian-vault/01_notes/04.2_moos_tracking_mission.md`
- **Quick Start Guide**: `obsidian-vault/01_notes/04.2.2_quickstart_guide.md`
- **A1 Plan**: `obsidian-vault/01_notes/A1_HEURISTIC_BASELINE_PLAN.md`
- **Methodology**: `obsidian-vault/01_notes/02_methodology.md`

## Support

For issues or questions:
1. Check `alog` files in `logs/` for error messages
2. Review behavior conditions in `.bhv` files
3. Verify MOOSDB variables in uMAC console
4. See documentation in `obsidian-vault/`

---

**Mission Status**: Phase 0 Complete ✅  
**Date Created**: December 14, 2024  
**MOOS-IvP Version**: Jul2724  
**Location**: Monterey Bay, CA
