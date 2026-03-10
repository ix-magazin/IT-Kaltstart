#!/bin/bash

# backup storage host

set -euo pipefail

BACKUP_ROOT="/var/backups/system-config"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

mkdir -p "$BACKUP_DIR"

echo "== Starte System-Konfigurationsbackup =="

# ==============================
# 1. Basis System Informationen
# ==============================

mkdir -p "$BACKUP_DIR/system"

uname -a > "$BACKUP_DIR/system/uname.txt"
lsb_release -a > "$BACKUP_DIR/system/os-release.txt" 2>/dev/null || true
dpkg --get-selections > "$BACKUP_DIR/system/installed-packages.txt"
apt-mark showmanual > "$BACKUP_DIR/system/manual-packages.txt"
systemctl list-unit-files > "$BACKUP_DIR/system/systemd-units.txt"

# ==============================
# 2. Netzwerk
# ==============================

mkdir -p "$BACKUP_DIR/network"

cp -a /etc/network "$BACKUP_DIR/network/" 2>/dev/null || true
cp -a /etc/systemd/network "$BACKUP_DIR/network/" 2>/dev/null || true
cp -a /etc/netplan "$BACKUP_DIR/network/" 2>/dev/null || true
cp -a /etc/hosts "$BACKUP_DIR/network/" || true
cp -a /etc/resolv.conf "$BACKUP_DIR/network/" || true

ip addr show > "$BACKUP_DIR/network/ip_addr.txt"
ip route show > "$BACKUP_DIR/network/ip_route.txt"
ss -tulpen > "$BACKUP_DIR/network/listening_ports.txt"

# ==============================
# 3. Firewall
# ==============================

mkdir -p "$BACKUP_DIR/firewall"

iptables-save > "$BACKUP_DIR/firewall/iptables.txt" 2>/dev/null || true
nft list ruleset > "$BACKUP_DIR/firewall/nftables.txt" 2>/dev/null || true

# ==============================
# 4. OpenZFS
# ==============================

mkdir -p "$BACKUP_DIR/zfs"

zpool status > "$BACKUP_DIR/zfs/zpool-status.txt"
zpool list > "$BACKUP_DIR/zfs/zpool-list.txt"
zfs list -t all > "$BACKUP_DIR/zfs/zfs-list.txt"
zfs get all > "$BACKUP_DIR/zfs/zfs-get-all.txt"

cp -a /etc/zfs "$BACKUP_DIR/zfs/" 2>/dev/null || true
cp -a /etc/modprobe.d/zfs.conf "$BACKUP_DIR/zfs/" 2>/dev/null || true

# Optional Snapshot aller Pools
for pool in $(zpool list -H -o name); do
    zfs snapshot -r ${pool}@config-backup-${TIMESTAMP}
done

# ==============================
# 5. NFS Server
# ==============================

mkdir -p "$BACKUP_DIR/nfs"

cp -a /etc/exports "$BACKUP_DIR/nfs/" 2>/dev/null || true
cp -a /etc/exports.d "$BACKUP_DIR/nfs/" 2>/dev/null || true
exportfs -v > "$BACKUP_DIR/nfs/active-exports.txt" 2>/dev/null || true

# ==============================
# 6. S3 Dienst (z.B. MinIO)
# ==============================

mkdir -p "$BACKUP_DIR/s3"

# typische MinIO Orte
cp -a /etc/minio "$BACKUP_DIR/s3/" 2>/dev/null || true
cp -a /etc/default/minio "$BACKUP_DIR/s3/" 2>/dev/null || true
cp -a /etc/systemd/system/minio.service "$BACKUP_DIR/s3/" 2>/dev/null || true

systemctl status minio > "$BACKUP_DIR/s3/minio-status.txt" 2>/dev/null || true

# ==============================
# 7. Fileservices (Samba optional)
# ==============================

mkdir -p "$BACKUP_DIR/fileservice"

cp -a /etc/samba "$BACKUP_DIR/fileservice/" 2>/dev/null || true
testparm -s > "$BACKUP_DIR/fileservice/samba-effective-config.txt" 2>/dev/null || true

# ==============================
# 8. Benutzer & Rechte
# ==============================

mkdir -p "$BACKUP_DIR/security"

getent passwd > "$BACKUP_DIR/security/passwd.txt"
getent group > "$BACKUP_DIR/security/group.txt"
cp -a /etc/shadow "$BACKUP_DIR/security/" 2>/dev/null || true

# sudo
cp -a /etc/sudoers "$BACKUP_DIR/security/" 2>/dev/null || true
cp -a /etc/sudoers.d "$BACKUP_DIR/security/" 2>/dev/null || true

# ==============================
# 9. Cron Jobs
# ==============================

mkdir -p "$BACKUP_DIR/cron"

cp -a /etc/crontab "$BACKUP_DIR/cron/" 2>/dev/null || true
cp -a /etc/cron.d "$BACKUP_DIR/cron/" 2>/dev/null || true
crontab -l > "$BACKUP_DIR/cron/root-crontab.txt" 2>/dev/null || true

# ==============================
# 10. Logs & Journal Konfiguration
# ==============================

mkdir -p "$BACKUP_DIR/logging"

cp -a /etc/rsyslog.conf "$BACKUP_DIR/logging/" 2>/dev/null || true
cp -a /etc/systemd/journald.conf "$BACKUP_DIR/logging/" 2>/dev/null || true

# ==============================
# 11. Komprimieren
# ==============================

tar -czf "${BACKUP_DIR}.tar.gz" -C "$BACKUP_ROOT" "$TIMESTAMP"
rm -rf "$BACKUP_DIR"

echo "== Backup abgeschlossen: ${BACKUP_DIR}.tar.gz =="

