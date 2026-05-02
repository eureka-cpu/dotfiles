#!/usr/bin/env python3

import sys

sys.stdout.reconfigure(line_buffering=True)

import time
import re
from pathlib import Path

# Temperature thresholds (in millidegrees C)
TEMP_CRIT = 85000
TEMP_HIGH = 80000
TEMP_MID = 75000
TEMP_LOW = 65000

POLL_INTERVAL = 2


def get_available_frequencies():
    """Read available frequencies from the system."""
    freq_file = Path(
        "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"
    )

    try:
        freqs = [int(f) for f in freq_file.read_text().strip().split()]
        freqs.sort(reverse=True)
        return freqs
    except (IOError, ValueError):
        return []


def get_current_max_freq():
    """Read current max frequency from the system."""
    freq_file = Path("/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq")

    try:
        return int(freq_file.read_text().strip())
    except (IOError, ValueError):
        return 0


def pick_freq_steps(freqs):
    """Pick 4 frequency steps from available frequencies."""
    if len(freqs) < 4:
        return freqs[0], freqs[0], freqs[-1], freqs[-1]

    full = freqs[0]
    minimum = freqs[-1]
    mid = freqs[len(freqs) // 3]
    low = freqs[2 * len(freqs) // 3]

    return full, mid, low, minimum


def get_cpu_thermal_zones():
    """Find all CPU-related thermal zones."""
    zones = []
    thermal_path = Path("/sys/class/thermal")

    for zone in thermal_path.glob("thermal_zone*"):
        type_file = zone / "type"
        if type_file.exists():
            zone_type = type_file.read_text().strip()
            if re.match(r"(cpuss|cpu[0-2]-)", zone_type):
                zones.append(zone)

    return zones


def get_max_temp(zones):
    """Get the maximum temperature across all CPU zones."""
    max_temp = 0

    for zone in zones:
        temp_file = zone / "temp"
        try:
            temp = int(temp_file.read_text().strip())
            max_temp = max(max_temp, temp)
        except (IOError, ValueError):
            pass

    return max_temp


def set_max_freq(freq):
    """Set maximum frequency for all CPUs."""
    cpu_path = Path("/sys/devices/system/cpu")

    for freq_file in cpu_path.glob("cpu*/cpufreq/scaling_max_freq"):
        try:
            freq_file.write_text(str(freq))
        except IOError:
            pass


def main():
    zones = get_cpu_thermal_zones()

    if not zones:
        print("No CPU thermal zones found!")
        return

    freqs = get_available_frequencies()

    if not freqs:
        print("Could not read available frequencies!")
        return

    freq_full, freq_mid, freq_low, freq_min = pick_freq_steps(freqs)

    print(f"Monitoring {len(zones)} CPU thermal zones")
    print(
        f"Frequency steps: {freq_full // 1000}MHz -> {freq_mid // 1000}MHz -> {freq_low // 1000}MHz -> {freq_min // 1000}MHz"
    )
    print(
        f"Temp thresholds: {TEMP_MID // 1000}°C -> {TEMP_HIGH // 1000}°C -> {TEMP_CRIT // 1000}°C"
    )

    while True:
        temp = get_max_temp(zones)
        current_cap = get_current_max_freq()

        if temp >= TEMP_CRIT:
            target = freq_min
        elif temp >= TEMP_HIGH:
            target = freq_low
        elif temp >= TEMP_MID:
            target = freq_mid
        elif temp < TEMP_LOW:
            target = freq_full
        else:
            target = current_cap

        if target != current_cap:
            set_max_freq(target)
            print(f"Temp: {temp // 1000}°C -> cap: {target // 1000}MHz")

        time.sleep(POLL_INTERVAL)


if __name__ == "__main__":
    main()
