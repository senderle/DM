FROM node:8-alpine



## The below is pasted from the maven:3-jdk-13 Dockerfile:
# https://github.com/carlossg/docker-maven/blob/3d97cfcd4a2de189542db8e3f618cf168b262168/jdk-13/Dockerfile

RUN apk add --no-cache curl tar bash procps python2 nss openjdk8

ARG MAVEN_VERSION=3.6.0
ARG USER_HOME_DIR="/root"
ARG SHA=fae9c12b570c3ba18116a4e26ea524b29f7279c17cbaadc3326ca72927368924d9131d11b9e851b8dc9162228b6fdea955446be41207a5cfc61283dd8a561d2f
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

RUN mkdir -p /var/www/dm
COPY ./package.json /var/www/dm/package.json
COPY ./pom.xml /var/www/dm/pom.xml
COPY ./scripts /var/www/dm/scripts
COPY ./src /var/www/dm/src
COPY ./webpack.config.js /var/www/dm/webpack.config.js
COPY ./yarn.lock /var/www/dm/yarn.lock

WORKDIR /var/www/dm
RUN scripts/build

COPY ./local.conf /var/www/dm/local.conf
