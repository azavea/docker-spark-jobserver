# docker-spark-jobserver

[![Docker Repository on Quay.io](https://quay.io/repository/azavea/spark-jobserver/status "Docker Repository on Quay.io")](https://quay.io/repository/azavea/spark-jobserver)
[![Apache V2 License](http://img.shields.io/badge/license-Apache%20V2-blue.svg)](https://github.com/azavea/docker-spark-jobserver/blob/develop/LICENSE)

A `Dockerfile` based off of [`azavea/spark`](https://quay.io/repository/azavea/spark) that launches an instance of [Spark Job Server](https://github.com/spark-jobserver/spark-jobserver).

## Usage

First, build the container with either of the following commands:

```bash
$ docker build -t quay.io/azavea/spark-jobserver:latest .
```

Or:

```bash
$ make build
```

Now you can run the container and provide any custom flags to the `spark-submit` command used to launch the Job Server:

```bash
$ docker run -ti -p 8090:8090 --name spark-jobserver --driver-memory 2G
```

## Testing

In order to quickly confirm that things are working, the `test` target of the `Makefile` can be used to chains together the commands (run within the container) required to:

- Build a test job JAR
- Upload the JAR to the Spark Job Server
- Execute an the JAR with custom input over HTTP

Below is some example output from running the test:

```
❯ make test
docker run --detach -p 8090:8090 --name spark-jobserver azavea/spark-jobserver
19642d7ee4e308a151ddc75b40e58affee2d010569a48dde05a0cfa1e84dde82
docker exec -ti spark-jobserver /bin/sh -c 'cd /tmp/spark-jobserver && sbt job-server-tests/package'
[info] Loading project definition from /tmp/spark-jobserver/project
[info] Set current project to root (in build file:/tmp/spark-jobserver/)
[info] scalastyle using config /tmp/spark-jobserver/scalastyle-config.xml
[info] Processed 5 file(s)
[info] Found 0 errors
[info] Found 0 warnings
[info] Found 0 infos
[info] Finished in 13 ms
[success] created output: /tmp/spark-jobserver/job-server-tests/target
[info] Updating {file:/tmp/spark-jobserver/}job-server-api...
[info] Resolving org.fusesource.jansi#jansi;1.4 ...
[info] Done updating.
[info] Updating {file:/tmp/spark-jobserver/}job-server-tests...
[info] Resolving org.fusesource.jansi#jansi;1.4 ...
[info] Done updating.
[info] scalastyle using config /tmp/spark-jobserver/scalastyle-config.xml
[info] Processed 3 file(s)
[info] Found 0 errors
[info] Found 0 warnings
[info] Found 0 infos
[info] Finished in 2 ms
[success] created output: /tmp/spark-jobserver/job-server-api/target
[info] Compiling 3 Scala sources to /tmp/spark-jobserver/job-server-api/target/scala-2.10/classes...
[info] Compiling 5 Scala sources to /tmp/spark-jobserver/job-server-tests/target/scala-2.10/classes...
[info] Packaging /tmp/spark-jobserver/job-server-tests/target/scala-2.10/job-server-tests_2.10-0.5.2-SNAPSHOT.jar ...
[info] Done packaging.
[success] Total time: 36 s, completed Jul 22, 2015 9:29:28 PM
docker exec -ti spark-jobserver curl --silent --data-binary @/tmp/spark-jobserver/job-server-tests/target/scala-2.10/job-server-tests_2.10-0.5.2-SNAPSHOT.jar \
                'http://localhost:8090/jars/test'
OKdocker exec -ti spark-jobserver curl --silent --data 'input.string = a b c a b see' \
                'http://localhost:8090/jobs?sync=true&appName=test&classPath=spark.jobserver.WordCountExample'
{
  "status": "OK",
  "result": {
    "a": 2,
    "b": 2,
    "see": 1,
    "c": 1
  }
}
```
