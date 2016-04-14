$#/bin/sh

# Available governors: ondemand, userspace, powersave, performance
# Default governor: ondemand
# Not supported by this script: userspace

# Get the /sys tree path to the governor setting.
GOV=$(kdb get system/driver/cpu/SYS_CPU_GOVERNOR 2>/dev/null)

# The requested governor.
REQ=$1

# Set selected.
echo $REQ > $GOV

exit 0
