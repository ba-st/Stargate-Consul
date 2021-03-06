# Stage 1: Load the project
FROM basmalltalk/pharo:8.0-image AS loader
ARG BRANCH_NAME=release-candidate
COPY load-project.st ./
RUN pharo Pharo.image load-project.st --save --quit

# Stage 2: Copy the resulting Pharo.image with our project loaded
# into a new docker image with just the vm
FROM basmalltalk/pharo:8.0

USER root

RUN apt-get update \
    && apt-get --assume-yes --no-install-recommends install curl \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/Stargate-Consul-Example-API
COPY api-start.sh ./
COPY --from=loader /opt/pharo/pharo-local/iceberg/ba-st/Stargate/docker/api-init.sh ./
COPY --from=loader /opt/pharo/pharo-local/iceberg/ba-st/Stargate/docker/health-check.sh ./
COPY --from=loader /opt/pharo/Pharo.image ./
COPY --from=loader /opt/pharo/Pharo.changes ./
COPY --from=loader /opt/pharo/Pharo*.sources ./

RUN mkdir logs \
  && chmod a+x api-init.sh \
  && chmod a+x api-start.sh \
  && chmod a+x health-check.sh \
  && chown --recursive pharo:users /opt/Stargate-Consul-Example-API

USER pharo
EXPOSE 8080

HEALTHCHECK CMD /opt/Stargate-Consul-Example-API/health-check.sh

CMD ["./api-init.sh"]
