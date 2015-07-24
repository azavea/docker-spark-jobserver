SCALA_MAJOR_VERSION=2.10

DOCKER_RUN_FLAGS = --detach -p 8090:8090 --name spark-jobserver
DOCKER_IMAGE_NAME = azavea/spark-jobserver

JOBSERVER_VERSION=0.5.2-SNAPSHOT
JOBSERVER_FLAGS =
JOBSERVER_ENDPOINT = http://localhost:8090
JOBSERVER_TEST_PATH = /tmp/spark-jobserver/job-server-tests/target/scala-$(SCALA_MAJOR_VERSION)
JOBSERVER_TEST_JAR = job-server-tests_$(SCALA_MAJOR_VERSION)-$(JOBSERVER_VERSION).jar
JOBSERVER_TEST_CLASS = spark.jobserver.WordCountExample

all: build

build:
	docker build -t $(DOCKER_IMAGE_NAME) .

clean:
	docker kill spark-jobserver || true
	docker rm spark-jobserver || true

test: clean
	docker run $(DOCKER_RUN_FLAGS) $(DOCKER_IMAGE_NAME) $(JOBSERVER_FLAGS)
	docker exec -ti spark-jobserver /bin/sh -c 'cd /tmp/spark-jobserver && sbt job-server-tests/package'
	docker exec -ti spark-jobserver curl --silent --data-binary @$(JOBSERVER_TEST_PATH)/$(JOBSERVER_TEST_JAR) \
		'$(JOBSERVER_ENDPOINT)/jars/test'
	docker exec -ti spark-jobserver curl --silent --data 'input.string = a b c a b see' \
		'$(JOBSERVER_ENDPOINT)/jobs?sync=true&appName=test&classPath=$(JOBSERVER_TEST_CLASS)'

.PHONY: all build clean test
