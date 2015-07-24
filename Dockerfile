FROM java:7

RUN apt-get update && apt-get install -y git --no-install-recommends

ENV SCALA_VERSION 2.10.5
ENV SCALA_MAJOR_VERSION 2.10
ENV SCALA_HOME /usr/local/share/scala
ENV PATH ${PATH}:${SCALA_HOME}/bin

RUN mkdir -p ${SCALA_HOME}
RUN wget -qO- http://www.scala-lang.org/files/archive/scala-${SCALA_VERSION}.tgz \
  | tar -xzC ${SCALA_HOME} --strip-components=1

ENV SBT_VERSION 0.13.8

RUN wget -qO- https://dl.bintray.com/sbt/debian/sbt-${SBT_VERSION}.deb > /tmp/sbt.deb \
  && dpkg -i /tmp/sbt.deb \
  && rm -rf /tmp/sbt.deb

ENV SPARK_VERSION 1.3.1
ENV SPARK_HOME /opt/spark
ENV SPARK_CONF_DIR ${SPARK_HOME}/conf

RUN mkdir -p ${SPARK_HOME}
RUN wget -qO- http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz \
  | tar -xzC ${SPARK_HOME} --strip-components=1

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
