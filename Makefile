DOCKER_RUN_FLAGS = --detach -p 8090:8090 --name spark-jobserver
DOCKER_IMAGE_NAME = quay.io/azavea/spark-jobserver:latest

JOBSERVER_FLAGS =

all: build

build:
	docker build -t $(DOCKER_IMAGE_NAME) .

clean:
	docker kill spark-jobserver || true
	docker rm spark-jobserver || true

test: clean
	docker run $(DOCKER_RUN_FLAGS) $(DOCKER_IMAGE_NAME) $(JOBSERVER_FLAGS)
	docker exec spark-jobserver /bin/sh -c 'cd /opt/spark-jobserver && ./test.sh'

.PHONY: all build clean test
