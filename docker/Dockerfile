# Stage 1: Load the project
FROM ghcr.io/ba-st/pharo-loader:v10.0.0 AS loader

COPY ./source ./source
COPY ./.git ./.git
RUN pharo metacello install gitlocal://./source \
  BaselineOfStargateConsul --groups=Examples

# Stage 2: Copy the resulting Pharo.image
FROM ghcr.io/ba-st/pharo:v10.0.0

USER root

RUN apt-get update \
    && apt-get --assume-yes --no-install-recommends install curl \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY docker/api-start.sh ./
COPY --from=loader /opt/pharo/pharo-local/iceberg/ba-st/Stargate/docker/api-init.sh ./
COPY --from=loader /opt/pharo/pharo-local/iceberg/ba-st/Stargate/docker/health-check.sh ./
COPY --from=loader /opt/pharo/Pharo.image ./
COPY --from=loader /opt/pharo/Pharo.changes ./
COPY --from=loader /opt/pharo/Pharo*.sources ./

RUN mkdir logs \
  && chmod a+x api-init.sh \
  && chmod a+x api-start.sh \
  && chmod a+x health-check.sh \
  && chown --recursive pharo:users /opt/pharo

USER pharo

HEALTHCHECK CMD ./health-check.sh

CMD ["./api-init.sh"]
