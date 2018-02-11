FROM ubuntu:latest
MAINTAINER Sean Johnson <sean@ttys0.net>

#Spigot Build
ENV FILE_BUILDTOOL https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
ARG SPIGOT_REV="1.12.2"
ENV SPIGOT_REV ${SPIGOT_REV}
ENV SPIGOT_BUILD_REV="latest"
ENV OUTPUT="/spigot/"

RUN apt-get update && apt-get -y install git tar openjdk-8-jre-headless wget

RUN wget -O BuildTools.jar ${FILE_BUILDTOOL}

RUN java -jar BuildTools.jar --rev ${SPIGOT_BUILD_REV}

RUN mkdir ${OUTPUT}

# Need to use "sh -c" to interpret the ENV values
CMD [ "/bin/sh", "-c", "cp spigot-${SPIGOT_REV}.jar ${OUTPUT}/spigot.jar ; cp craftbukkit-${SPIGOT_REV}.jar ${OUTPUT}/craftbukkit.jar" ]
