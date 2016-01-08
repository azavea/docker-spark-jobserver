FROM quay.io/azavea/spark:1.5.2

MAINTAINER Azavea <systems@azavea.com>

ENV SPARK_JOBSERVER_VERSION 0.6.1
ENV SPARK_JOBSERVER_SRC_HOME /usr/local/src
ENV SPARK_JOBSERVER_HOME /opt/spark-jobserver

RUN mkdir -p ${SPARK_JOBSERVER_SRC_HOME} ${SPARK_JOBSERVER_HOME} \
  && wget -qO- https://github.com/spark-jobserver/spark-jobserver/archive/v${SPARK_JOBSERVER_VERSION}.tar.gz	\
  | tar -xzC ${SPARK_JOBSERVER_SRC_HOME}

WORKDIR ${SPARK_JOBSERVER_SRC_HOME}/spark-jobserver-${SPARK_JOBSERVER_VERSION}

RUN sbt ++${SCALA_VERSION} job-server-extras/assembly \
  && mv job-server-extras/target/scala-2.10/spark-job-server.jar ${SPARK_JOBSERVER_HOME} \
  && rm -rf ~/.ivy2/cache/

COPY etc/spark-jobserver.conf ${SPARK_JOBSERVER_HOME}/
COPY etc/log4j.properties ${SPARK_JOBSERVER_HOME}/
COPY bin/*.sh ${SPARK_JOBSERVER_HOME}/

VOLUME /opt/spark-jobserver/jars
VOLUME /opt/spark-jobserver/filedao/data

WORKDIR ${SPARK_JOBSERVER_HOME}

ENTRYPOINT ["./docker-entrypoint.sh"]
