#!/usr/bin/env python3

import pynetbox
import subprocess
import os

# ===============================
# Konfiguration
# ===============================

NETBOX_URL = "https://cmdb.case.org"
NETBOX_TOKEN = os.getenv("NETBOX_TOKEN")  # Token via ENV setzen!
OUTPUT_FILE = "aruba_devices_sorted.txt"

# ===============================
# NetBox Verbindung
# ===============================

nb = pynetbox.api(NETBOX_URL, token=NETBOX_TOKEN)

devices = nb.dcim.devices.filter(platform="Aruba-OS")

results = []

for device in devices:

    if not device.primary_ip4:
        continue

    ip = device.primary_ip4.address.split("/")[0]

    try:
        # Traceroute ausführen (numerisch, max 30 Hops)
        proc = subprocess.run(
            ["traceroute", "-n", "-m", "30", ip],
            capture_output=True,
            text=True,
            timeout=30
        )

        output_lines = proc.stdout.strip().split("\n")

        # Erste Zeile ist Header → Hops zählen
        hop_count = len(output_lines) - 1

        results.append((ip, hop_count))

        print(f"{ip} → {hop_count} Hops")

    except Exception as e:
        print(f"Fehler bei {ip}: {e}")

# ===============================
# Sortierung: größte Distanz zuerst
# ===============================

results.sort(key=lambda x: x[1], reverse=True)

# ===============================
# Ausgabe in Datei
# ===============================

with open(OUTPUT_FILE, "w") as f:
    for ip, dist in results:
        f.write(f"{ip}\n")

print(f"\nFertig. Ausgabe in {OUTPUT_FILE}")
