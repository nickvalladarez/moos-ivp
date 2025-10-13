# MOOS-IvP Mission Builder GUI

A web-based graphical interface for creating MOOS-IvP missions with visual waypoint planning and behavior configuration.

## Features

### Current Prototype Features
- **Interactive Map**: Click-to-add waypoints on OpenStreetMap
- **Mission Configuration**: Set basic mission parameters (name, community, vehicle type)
- **Coordinate System**: Configure lat/lon origin for local coordinate conversion
- **Waypoint Management**: Add, remove, and visualize waypoints with route planning
- **Behavior Configuration**: Basic support for waypoint, station-keep, and loiter behaviors
- **File Generation**: Export .moos and .bhv files ready for MOOS-IvP
- **Mission Preview**: Summary view of mission parameters and estimated duration

### Python Backend Features
- **Coordinate Conversion**: Proper lat/lon to local MOOS coordinate transformation
- **File Generation**: Programmatic creation of MOOS configuration files
- **JSON Import/Export**: Save and load mission configurations
- **Command Line Interface**: Generate missions from command line arguments
- **Behavior Templates**: Pre-configured behavior patterns for common missions

## Quick Start

### Web Interface
1. Open `index.html` in a web browser
2. Configure mission parameters in the sidebar
3. Click "Add Waypoint" and click on the map to place waypoints
4. Configure behaviors as needed
5. Click "Generate .moos File" and "Generate .bhv File" to download

### Python Backend
```bash
# Generate a simple waypoint mission
python3 mission_builder.py --waypoints "43.825,-70.330;43.826,-70.329" --mission-name "test_survey" --community "alpha"

# Generate from JSON configuration
python3 mission_builder.py --json mission_config.json --output my_mission
```

## Project Structure

```
mission-builder-gui/
├── index.html              # Web-based GUI interface
├── mission_builder.py      # Python backend for file generation
├── README.md              # This file
└── examples/              # Example mission configurations
    ├── basic_survey.json
    ├── station_keeping.json
    └── multi_behavior.json
```

## Technical Architecture

### Frontend (Web Interface)
- **HTML5/CSS3/JavaScript**: Core web technologies
- **Leaflet.js**: Interactive mapping with OpenStreetMap tiles
- **Responsive Design**: Works on desktop and tablet devices
- **Local Coordinate Conversion**: Approximate lat/lon to MOOS coordinates

### Backend (Python)
- **Coordinate Conversion**: Accurate geodetic transformations
- **Template System**: Configurable behavior and mission templates
- **File Generation**: Standards-compliant MOOS configuration files
- **JSON Schema**: Structured mission data format

## Integration with MOOS-IvP

Generated files are compatible with standard MOOS-IvP workflows:

```bash
# Launch generated mission
cd /path/to/generated/files
pAntler mission_name.moos

# View in pMarineViewer
pMarineViewer mission_name.moos
```

## Mission Configuration Format

The mission builder uses a JSON schema for storing mission configurations:

```json
{
  "config": {
    "mission_name": "survey_mission",
    "community": "alpha",
    "time_warp": 1,
    "lat_origin": 43.825300,
    "lon_origin": -70.330400,
    "vehicle_type": "kayak",
    "cruise_speed": 3.0,
    "capture_radius": 5.0
  },
  "waypoints": [
    {"lat": 43.825300, "lon": -70.330400, "name": "WP1"},
    {"lat": 43.826000, "lon": -70.329000, "name": "WP2"}
  ],
  "behaviors": [
    {
      "type": "waypoint",
      "name": "survey_pattern",
      "params": {"priority": 100, "speed": 3.0}
    }
  ]
}
```

## Supported Vehicle Types
- Kayak (default)
- AUV (Autonomous Underwater Vehicle)
- USV (Unmanned Surface Vehicle)
- Ship

## Supported Behaviors
- **BHV_Waypoint**: Sequential waypoint following
- **BHV_StationKeep**: Station keeping at a location
- **BHV_Loiter**: Loitering in a defined area
- **BHV_ConstantHeading**: Maintain constant heading and speed

## Development Roadmap

### Phase 1: Basic Mission Builder (Current)
- ✅ Web-based waypoint editor
- ✅ Basic behavior configuration
- ✅ MOOS/BHV file generation
- ✅ Python backend integration

### Phase 2: Enhanced Features
- [ ] Advanced behavior editor with form-based configuration
- [ ] Mission templates and presets
- [ ] Real-time mission validation
- [ ] Simulation integration preview
- [ ] Multi-vehicle mission support

### Phase 3: Professional Tools
- [ ] Integration with MOOS database
- [ ] Real-time vehicle status monitoring
- [ ] Mission replay and analysis tools
- [ ] Advanced coordinate system support (UTM, local grids)
- [ ] Plugin architecture for custom behaviors

## Dependencies

### Web Interface
- Modern web browser with JavaScript support
- Internet connection for map tiles (or local tile server)

### Python Backend
- Python 3.6+
- Standard library only (no external dependencies)

## Browser Compatibility
- Chrome/Chromium 80+
- Firefox 75+
- Safari 13+
- Edge 80+

## Known Limitations
- Coordinate conversion uses simplified approximation (adequate for most use cases)
- Web interface is prototype-level (basic styling and error handling)
- Limited behavior parameter customization in GUI
- No real-time validation of MOOS syntax

## Contributing

This is a prototype implementation. Potential improvements:

1. **Enhanced Coordinate Conversion**: Implement proper UTM or local grid projections
2. **Advanced Behavior Editor**: Form-based configuration for all behavior parameters
3. **Mission Validation**: Real-time checking of mission syntax and feasibility
4. **Template System**: Pre-built mission templates for common scenarios
5. **Integration Testing**: Automated validation with MOOS-IvP simulation

## License

This tool is designed to work with MOOS-IvP, which is released under the GPL v3 license. This mission builder follows the same licensing terms.

## Examples

See the `examples/` directory for sample mission configurations that demonstrate various use cases:

- **basic_survey.json**: Simple waypoint survey mission
- **station_keeping.json**: Station keeping with emergency return behavior
- **multi_behavior.json**: Complex mission with multiple behaviors and conditions

## Support

For issues related to:
- **MOOS-IvP Integration**: Consult MOOS-IvP documentation and community
- **Mission Builder Bugs**: Check generated file syntax against MOOS standards
- **Feature Requests**: Consider implementing as pull requests or extensions

---

**Note**: This is a prototype implementation designed to demonstrate the feasibility of creating a GUI mission builder for MOOS-IvP. Production use would require additional testing, validation, and integration with the broader MOOS-IvP ecosystem.
