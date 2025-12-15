#!/bin/bash
#------------------------------------------------------
# Launch Script: A1 Heuristic Baseline Mission
# Phase 0: 3 AUVs + 1 Target with perfect sensors/comms
#------------------------------------------------------

TIME_WARP=1
JUST_MAKE="no"

#------------------------------------------------------
# Parse command line arguments
#------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
        echo "launch.sh [SWITCHES]"
        echo "  --help, -h         Show this help message"
        echo "  --just_make, -j    Just create files, don't launch"
        echo "  --warp=VALUE       Set time warp (default: 1)"
        echo "  NUMBER             Set time warp to NUMBER"
        exit 0
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then
        TIME_WARP=$ARGI
    elif [ "${ARGI}" = "--just_make" -o "${ARGI}" = "-j" ] ; then
        JUST_MAKE="yes"
    elif [ "${ARGI:0:6}" = "--warp" ] ; then
        TIME_WARP="${ARGI#--warp=*}"
    fi
done

#------------------------------------------------------
# Generate MOOS files using nsplug
#------------------------------------------------------
echo "Generating MOOS configuration files..."

# AUV 0 (Pinger)
nsplug meta_vehicle.moos targ_auv_0.moos -f \
    WARP=$TIME_WARP \
    VNAME=auv_0 \
    VPORT=9001 \
    VCOLOR=blue \
    START_POS="0,-50,50,0" \
    ROLE=pinger

nsplug meta_vehicle.bhv targ_auv_0.bhv -f \
    VNAME=auv_0 \
    START_POS="0,-50" \
    ROLE=pinger \
    PURSUIT_POINTS="100,0:200,0"

# AUV 1 (Left Shadower)
nsplug meta_vehicle.moos targ_auv_1.moos -f \
    WARP=$TIME_WARP \
    VNAME=auv_1 \
    VPORT=9002 \
    VCOLOR=cyan \
    START_POS="-60,-80,50,90" \
    ROLE=shadower_left

nsplug meta_vehicle.bhv targ_auv_1.bhv -f \
    VNAME=auv_1 \
    START_POS="-60,-80" \
    ROLE=shadower_left \
    PURSUIT_POINTS="100,-50:200,-50"

# AUV 2 (Right Shadower)
nsplug meta_vehicle.moos targ_auv_2.moos -f \
    WARP=$TIME_WARP \
    VNAME=auv_2 \
    VPORT=9003 \
    VCOLOR=green \
    START_POS="60,-80,50,90" \
    ROLE=shadower_right

nsplug meta_vehicle.bhv targ_auv_2.bhv -f \
    VNAME=auv_2 \
    START_POS="60,-80" \
    ROLE=shadower_right \
    PURSUIT_POINTS="100,50:200,50"

# Target
nsplug meta_vehicle.moos targ_target.moos -f \
    WARP=$TIME_WARP \
    VNAME=target \
    VPORT=9004 \
    VCOLOR=red \
    START_POS="0,0,50,0" \
    ROLE=target

nsplug meta_target.bhv targ_target.bhv -f \
    VNAME=target

# Shoreside
nsplug meta_shoreside.moos targ_shoreside.moos -f \
    WARP=$TIME_WARP

if [ ${JUST_MAKE} = "yes" ] ; then
    echo "Files generated. Exiting without launch."
    exit 0
fi

#------------------------------------------------------
# Launch vehicles
#------------------------------------------------------
echo "Launching A1 Heuristic Baseline Mission..."
echo "Time warp: ${TIME_WARP}x"
echo ""

pAntler targ_auv_0.moos >& /dev/null &
echo "Launched AUV 0 (Pinger) on port 9001"
sleep 0.25

pAntler targ_auv_1.moos >& /dev/null &
echo "Launched AUV 1 (Left Shadower) on port 9002"
sleep 0.25

pAntler targ_auv_2.moos >& /dev/null &
echo "Launched AUV 2 (Right Shadower) on port 9003"
sleep 0.25

pAntler targ_target.moos >& /dev/null &
echo "Launched Target on port 9004"
sleep 0.25

pAntler targ_shoreside.moos >& /dev/null &
echo "Launched Shoreside (pMarineViewer) on port 9000"
sleep 0.5

echo ""
echo "=============================================="
echo "Mission launched successfully!"
echo "=============================================="
echo ""
echo "Instructions:"
echo "  1. pMarineViewer should open automatically"
echo "  2. Click 'DEPLOY' to start all vehicles"
echo "  3. Click 'TRACK' to enable tracking behaviors"
echo "  4. Watch the 3 AUVs coordinate to track the target"
echo "  5. Use CTRL-C in this terminal to exit"
echo ""
echo "Mission Parameters (Phase 0):"
echo "  - 3 AUVs: auv_0 (pinger), auv_1/auv_2 (shadowers)"
echo "  - 1 Target moving at 1.5 m/s"
echo "  - Perfect sensors (no noise)"
echo "  - Perfect communications (no packet loss)"
echo "  - Fixed depth: 50m"
echo "  - REMUS 100 dynamics"
echo "  - Location: Monterey Bay, CA"
echo ""

uMAC targ_shoreside.moos

echo "Killing all processes..."
killall pAntler >& /dev/null
killall uSimMarine >& /dev/null
killall pHelmIvP >& /dev/null
killall pMarineViewer >& /dev/null
killall pLogger >& /dev/null
killall uMAC >& /dev/null

echo "Mission terminated."
