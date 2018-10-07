#
# Scala and sbt Dockerfile
#
# https://github.com/hseeberger/scala-sbt
#

# Pull base image
FROM buildpack-deps:stretch-scm

# Env variables
ENV SCALA_VERSION 2.12.7
ENV SBT_VERSION 1.2.3
ENV JAVA_HOME /root/graal
ENV GRAAL_VERSION 1.0.0-rc7

# Install GraalVM
RUN \
  mkdir $JAVA_HOME && \
  curl -fsL https://github.com/oracle/graal/releases/download/vm-$GRAAL_VERSION/graalvm-ce-$GRAAL_VERSION-linux-amd64.tar.gz | tar xfz - -C $JAVA_HOME --strip-components=1

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/

RUN \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$JAVA_HOME/bin:$PATH' >> /root/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  rm -rf /var/lib/apt/lists/*

# Download sbt jars
# TODO: didn't find a good way to apply updated PATH from .bashrc here, so explicitly specified java home
RUN sbt -java-home $JAVA_HOME sbtVersion

# Create non-root user
RUN useradd -ms /bin/bash testuser

# Define working directory
WORKDIR /home/testuser
