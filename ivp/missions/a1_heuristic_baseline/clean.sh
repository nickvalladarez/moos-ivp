#!/bin/bash
#------------------------------------------------------
# Clean Script: Remove generated files and logs
#------------------------------------------------------

echo "Cleaning mission directory..."

# Remove generated target files
rm -f targ_*.moos targ_*.bhv

# Remove logs
rm -rf logs/
rm -rf MOOSLog_*
rm -rf XLOG_*

# Remove MOOS lock files
rm -f .LastOpenedMOOSLogDirectory

# Kill any running processes
killall pAntler >& /dev/null
killall uSimMarine >& /dev/null
killall pHelmIvP >& /dev/null
killall pMarineViewer >& /dev/null
killall pLogger >& /dev/null
killall pNodeReporter >& /dev/null
killall pMarinePID >& /dev/null
killall uFldNodeComms >& /dev/null
killall uFldContactRangeSensor >& /dev/null
killall uFldShoreBroker >& /dev/null
killall uTimerScript >& /dev/null
killall uMAC >& /dev/null
killall MOOSDB >& /dev/null

echo "Clean complete."
