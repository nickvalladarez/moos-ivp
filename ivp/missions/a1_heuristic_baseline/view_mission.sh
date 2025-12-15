#!/bin/bash
#------------------------------------------------------
# Script: view_mission.sh
# Quick mission log visualizer
#------------------------------------------------------

VISUALIZER="/home/ndvalla/Research/uuv-research/scripts/visualize_mission.py"

# Get the most recent log directory if none specified
if [ -z "$1" ]; then
    LOG_DIR=$(ls -td MOOSLog_* 2>/dev/null | head -1)
    if [ -z "$LOG_DIR" ]; then
        echo "No MOOS log directories found!"
        exit 1
    fi
    echo "Using latest log: $LOG_DIR"
else
    LOG_DIR="$1"
fi

# Output file
OUTPUT="${LOG_DIR}/mission_visualization.png"

# Run visualizer
echo "Generating visualization..."
python3 "$VISUALIZER" "$LOG_DIR" -o "$OUTPUT"

if [ -f "$OUTPUT" ]; then
    echo "✓ Visualization saved: $OUTPUT"
    xdg-open "$OUTPUT" 2>/dev/null &
else
    echo "✗ Failed to create visualization"
    exit 1
fi
