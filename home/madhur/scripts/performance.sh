#!/bin/bash
sudo cpupower frequency-set -g schedutil
sudo sh -c "echo '1' > /sys/devices/system/cpu/cpufreq/boost"
notify-send "Switched to schedutil"
