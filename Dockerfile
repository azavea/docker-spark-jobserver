FROM quay.io/azavea/spark:0.1.0

MAINTAINER Azavea <systems@azavea.com>

ENV SPARK_JOBSERVER_VERSION 0.5.2
ENV SPARK_JOBSERVER_HOME /opt/spark-jobserver

RUN mkdir -p ${SPARK_JOBSERVER_HOME} ${SPARK_JOBSERVER_BUILD} \
  && wget -qO ${SPARK_JOBSERVER_HOME}/spark-job-server.jar \
    https://github.com/azavea/spark-jobserver/releases/download/v${SPARK_JOBSERVER_VERSION}-azavea/spark-job-server.jar

WORKDIR ${SPARK_JOBSERVER_HOME}

COPY etc/spark-jobserver.conf ${SPARK_JOBSERVER_HOME}/
COPY etc/log4j.properties ${SPARK_JOBSERVER_HOME}/
COPY bin/*.sh ${SPARK_JOBSERVER_HOME}/

VOLUME /opt/spark-jobserver/jars
VOLUME /opt/spark-jobserver/filedao/data

ENTRYPOINT ["./docker-entrypoint.sh"]
