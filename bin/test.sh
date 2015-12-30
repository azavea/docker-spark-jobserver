#!/usr/bin/env bash

set -e

SPARK_JOBSERVER_VERSION="0.6.1"

apt-get update && apt-get install -y openjdk-7-jdk

pushd /usr/local/src/spark-jobserver-${SPARK_JOBSERVER_VERSION}

sbt job-server-tests/package

curl --silent --data-binary @"job-server-tests/target/scala-2.10/job-server-tests_2.10-${SPARK_JOBSERVER_VERSION}.jar" \
	'http://localhost:8090/jars/test'
curl --silent --data 'input.string = a b c a b see' \
	'http://localhost:8090/jobs?sync=true&appName=test&classPath=spark.jobserver.WordCountExample'
