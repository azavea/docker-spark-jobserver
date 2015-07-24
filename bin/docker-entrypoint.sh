#!/usr/bin/env bash

set -e

GC_OPTS="-XX:+UseConcMarkSweepGC -XX:MaxPermSize=512m -XX:+CMSClassUnloadingEnabled"
JAVA_OPTS="-XX:MaxDirectMemorySize=512M -XX:+HeapDumpOnOutOfMemoryError -Djava.net.preferIPv4Stack=true"
LOG_OPTS="-Dlog4j.configuration=file:log4j.properties"

exec /opt/spark/bin/spark-submit \
  --class spark.jobserver.JobServer \
  --driver-memory 1G \
  --conf "spark.executor.extraJavaOptions=${LOG_OPTS}" \
  --driver-java-options "$GC_OPTS $JAVA_OPTS $LOG_OPTS" \
  "$@" spark-job-server.jar spark-jobserver.conf 2>&1
