#!/bin/sh

set -e

REAPER_CONFIG="${REAPER_CONFIG:-/cassandra-reaper.yaml}"
REAPER_DB_PASSWD="${REAPER_DB_PASSWD}"
REAPER_MIN_HEAP="${REAPER_MIN_HEAP:-1G}"
REAPER_MAX_HEAP="${REAPER_MAX_HEAP:-2G}"
REAPER_JAR="${REAPER_JAR:-/cassandra-reaper-0.5.1-SNAPSHOT.jar}"

REAPER_SEGMENTCOUNT="${SEGMENTCOUNT:-200}"
REAPER_REPAIRPARALLELISM="${REPAIRPARALLELISM:-DATACENTER_AWARE}"
REAPER_REPAIRINTENSITY="${REPAIRINTENSITY:-0.9}"
REAPER_SCHEDULEDAYSBETWEEN="${SCHEDULEDAYSBETWEEN:-7}"
REAPER_REPAIRRUNTHREADCOUNT="${REPAIRRUNTHREADCOUNT:-15}"
REAPER_HANGINGREPAIRTIMEOUTMINS="${HANGINGREPAIRTIMEOUTMINS:-30}"

echo Starting Cassandra Reaper
echo REAPER_CONFIG ${REAPER_CONFIG}
echo REAPER_JAR ${REAPER_JAR}
echo REAPER_MIN_HEAP ${REAPER_MIN_HEAP}
echo REAPER_MAX_HEAP ${REAPER_MAX_HEAP}
echo REAPER_SEGMENTCOUNT ${REAPER_SEGMENTCOUNT}
echo REAPER_REPAIRPARALLELISM ${REAPER_REPAIRPARALLELISM}
echo REAPER_REPAIRINTENSITY ${REAPER_REPAIRINTENSITY}
echo REAPER_SCHEDULEDAYSBETWEEN ${REAPER_SCHEDULEDAYSBETWEEN}
echo REAPER_REPAIRRUNTHREADCOUNT ${REAPER_REPAIRRUNTHREADCOUNT}
echo REAPER_HANGINGREPAIRTIMEOUTMINS ${REAPER_HANGINGREPAIRTIMEOUTMINS}

sed -i "s/reaper-pass/${REAPER_DB_PASSWD}/" ${REAPER_CONFIG}

# TODO what else needs to be modified
for yaml in \
  segmentCount \
  repairParallelism \
  repairIntensity \
  scheduleDaysBetween \
  repairRunThreadCount \
  hangingRepairTimeoutMins \
  ; do
  var_upper=`echo "$yaml" | tr '[:lower:]' '[:upper:]'`
  var="REAPER_${var_upper}"
  eval "val=\$$var"
  if [ "$val" ]; then
    sed -ri 's/^(# )?('"$yaml"':).*/\2 '"$val"'/' "$REAPER_CONFIG"
  fi
done

/opt/jre/bin/java -Xms$REAPER_MIN_HEAP \
                  -Xmx$REAPER_MAX_HEAP \
                  -cp $REAPER_JAR \
                  com.spotify.reaper.ReaperApplication \
                  server \
                  $REAPER_CONFIG
