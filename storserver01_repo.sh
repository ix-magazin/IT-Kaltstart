#!/bin/bash

# ===== Konfiguration =====
REMOTE_HOST="192.168.1.2"
REMOTE_USER="remoteuser"
REMOTE_FILE="/tmp/cfg.txt"

LOCAL_REPO="/opt/config-repo"
LOCAL_FILE="$LOCAL_REPO/cfg.txt"

GIT_BRANCH="main"

# ===== Script Start =====

echo "==> Hole Datei von ${REMOTE_HOST}..."

scp ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_FILE} ${LOCAL_FILE}

if [ $? -ne 0 ]; then
    echo "Fehler beim Kopieren der Datei."
    exit 1
fi

echo "==> Wechsel in Repository..."
cd ${LOCAL_REPO} || exit 1

echo "==> Prüfe auf Änderungen..."

if git diff --quiet -- ${LOCAL_FILE}; then
    echo "Keine Änderungen erkannt."
    exit 0
fi

echo "==> Committe Änderungen..."

git add cfg.txt
git commit -m "Automatischer Import von ${REMOTE_HOST} am $(date '+%Y-%m-%d %H:%M:%S')"

echo "==> Push nach GitLab..."

git push origin ${GIT_BRANCH}

if [ $? -eq 0 ]; then
    echo "Push erfolgreich."
else
    echo "Push fehlgeschlagen."
    exit 1
fi

echo "==> Fertig."
