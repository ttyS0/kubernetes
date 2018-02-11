FROM openjdk:alpine

ARG MEM="1024M"
ENV JVM_OPTS="-Xms${MEM} -Xmx${MEM} -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:+AggressiveOpts"
ENV SPIGOT_OPTS="nogui --noconsole"

RUN mkdir -p /minecraft/server
ADD eula.txt /minecraft/server/

# jar files can be obtained via:
# docker run --rm -v $(pwd):/spigot spigot:latest
ADD spigot.jar /minecraft/
ADD craftbukkit.jar /minecraft/

WORKDIR /minecraft/server

# Expose the standard Minecraft port, and remote console port
EXPOSE 25565
EXPOSE 25575

CMD ["/bin/sh", "-c", "/usr/bin/java ${JVM_OPTS} -jar /minecraft/spigot.jar ${SPIGOT_OPTS}"]
