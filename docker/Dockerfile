# Stage 1: Load the project
FROM ghcr.io/ba-st/pharo-loader:v11.0.0 AS loader

COPY --chown=pharo:users ./source ./source
COPY --chown=pharo:users ./.git ./.git
RUN pharo metacello install gitlocal://. \
  BaselineOfStargateConsul --groups=Examples

# Stage 2: Copy the resulting Pharo.image
FROM ghcr.io/ba-st/launchpad:v5

COPY --from=loader --chown=pharo:users --chmod=755 /opt/pharo/pharo-local/iceberg/ba-st/Stargate/docker/health-check.sh ./
COPY --from=loader --chown=pharo:users /opt/pharo/Pharo.image ./
COPY --from=loader --chown=pharo:users /opt/pharo/Pharo.changes ./
COPY --from=loader --chown=pharo:users /opt/pharo/Pharo*.sources ./

RUN mkdir logs

HEALTHCHECK CMD ./health-check.sh

CMD ["launchpad-start", "stargate-consul-example"]
