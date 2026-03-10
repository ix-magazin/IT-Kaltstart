#!/bin/bash

set -e

POOL_NAME="tank"                     # <-- anpassen
DEVICE_PATH="/dev/disk/by-id"
ZPOOL_CACHE="/etc/zfs/zpool.cache"
START_SCRUB="yes"                     # yes / no

echo "=== ZFS Data Pool Import Script (Debian) ==="

# Root-Check
if [ "$EUID" -ne 0 ]; then
  echo "Bitte als root ausführen."
  exit 1
fi

echo "== verfügbare Blockdevices =="
lsblk

echo "== Suche nach importierbaren ZFS Pools =="
zpool import -d $DEVICE_PATH || true

echo "== versuche Pool '$POOL_NAME' zu importieren =="

if zpool import -d $DEVICE_PATH $POOL_NAME; then
  echo "Standard-Import erfolgreich."
else
  echo "Standard-Import fehlgeschlagen, versuche Force-Import..."
  zpool import -f -m -d $DEVICE_PATH $POOL_NAME
fi

echo "== setze Cachefile =="
zpool set cachefile=$ZPOOL_CACHE $POOL_NAME

echo "== Prüfe Pool Status =="
zpool status $POOL_NAME

echo "== Liste ZFS Datasets =="
zfs list

echo "== Mount aller Datasets =="
zfs mount -a

if [ "$START_SCRUB" == "yes" ]; then
  echo "== starte Scrub =="
  zpool scrub $POOL_NAME
fi

echo "=== Import abgeschlossen ==="
