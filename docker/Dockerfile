# Stage 1: Load the project
FROM ghcr.io/ba-st/pharo-loader:v11.0.0 AS loader

COPY --chown=pharo:users ./source ./source
COPY --chown=pharo:users ./.git ./.git
RUN pharo metacello install gitlocal://. \
  BaselineOfStargateConsul --groups=Examples

# Stage 2: Copy the resulting Pharo.image
FROM ghcr.io/ba-st/launchpad:v4

USER root

COPY --from=loader /opt/pharo/pharo-local/iceberg/ba-st/Stargate/docker/health-check.sh ./
COPY --from=loader /opt/pharo/Pharo.image ./
COPY --from=loader /opt/pharo/Pharo.changes ./
COPY --from=loader /opt/pharo/Pharo*.sources ./

RUN mkdir logs \
  && chmod a+x health-check.sh \
  && chown --recursive pharo:users /opt/pharo

USER pharo

HEALTHCHECK CMD ./health-check.sh

CMD ["launchpad-start", "stargate-consul-example"]
