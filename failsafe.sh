#!/bin/bash
# Run by .github/workflows/failsafe.yml (see README.md).
set -euo pipefail

if [ -f unlock.lic ]; then
    echo "The unlock is published already (unlock.lic). Nothing to do."
    exit 0
fi
case "${UNLOCK:-}" in
    *"BEGIN SDIDELAY UNLOCK"*) ;;
    "") echo "::error::The secret FAILSAFE_UNLOCK is empty: the failsafe can't fire. Add it (README, step 4)."; exit 1 ;;
    *)  echo "::error::The secret FAILSAFE_UNLOCK isn't an unlock file (it must contain BEGIN SDIDELAY UNLOCK)."; exit 1 ;;
esac
if [ ! -f alive.json ]; then
    echo "No alive.json yet: the licence server hasn't written one. Nothing to do."
    exit 0
fi

now=$(date -u +%s)
alive=$(python3 -c 'import json; print(int(json.load(open("alive.json"))["unix"]))')
age=$(( (now - alive) / 86400 ))
echo "Last heartbeat from the licence server: $(date -u -d "@$alive") — $age day(s) ago (unlock after $DAYS)."

publish=no
if [ "${PUBLISH_NOW:-}" = "YES" ]; then
    echo "Publishing by hand (the workflow was run with YES)."
    publish=yes
elif [ "$age" -ge "$DAYS" ]; then
    publish=yes
fi

if [ "$publish" = yes ]; then
    printf '%s\n' "$UNLOCK" > unlock.lic
    git config user.name "github-actions[bot]"
    git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
    git add unlock.lic
    git commit -m "Failsafe: unlock published (no heartbeat for $age days)"
    git push
    echo "::warning::THE UNLOCK IS PUBLISHED: every permanent SDIdelay Plus licence is now Broadcast."
    exit 0
fi

if [ "$age" -ge "$WARN_DAYS" ]; then
    echo "::error::No heartbeat for $age days — the unlock will be published in $(( DAYS - age )) day(s). Fix the licence server, or update alive.json by hand."
    exit 1
fi
echo "OK."
