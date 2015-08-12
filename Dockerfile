FROM quay.io/azavea/spark:0.1.0

RUN apt-get update && apt-get install -y git --no-install-recommends

ENV SPARK_JOBSERVER_VERSION master
ENV SPARK_JOBSERVER_HOME /opt/spark-jobserver

RUN mkdir -p ${SPARK_JOBSERVER_HOME}
RUN git clone https://github.com/spark-jobserver/spark-jobserver.git /tmp/spark-jobserver

WORKDIR /tmp/spark-jobserver

RUN sbt ++${SCALA_VERSION} job-server-extras/assembly

RUN cp job-server-extras/target/scala-${SCALA_MAJOR_VERSION}/spark-job-server.jar \
       job-server/config/log4j-server.properties ${SPARK_JOBSERVER_HOME} \
  && touch ${SPARK_JOBSERVER_HOME}/settings.sh

COPY etc/spark-jobserver.conf ${SPARK_JOBSERVER_HOME}/spark-jobserver.conf
COPY etc/log4j.properties ${SPARK_JOBSERVER_HOME}/log4j.properties
COPY bin/docker-entrypoint.sh ${SPARK_JOBSERVER_HOME}/docker-entrypoint.sh

VOLUME /opt/spark-jobserver/jars
VOLUME /opt/spark-jobserver/filedao/data

WORKDIR ${SPARK_JOBSERVER_HOME}

ENTRYPOINT ["./docker-entrypoint.sh"]
