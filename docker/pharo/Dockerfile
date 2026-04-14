# Stage 1: Load the project
FROM ghcr.io/ba-st/pharo-loader:v13.1.2 AS loader

COPY --chown=pharo:users ./source ./source
COPY --chown=pharo:users ./.git ./.git
RUN pharo metacello install gitlocal://. \
  BaselineOfStargateConsul --groups=Examples

# Stage 2: Copy the resulting Pharo.image
FROM ghcr.io/ba-st/launchpad:v8

COPY --from=loader --chown=pharo:users --chmod=755 /opt/pharo/pharo-local/iceberg/ba-st/Stargate/docker/health-check.sh ./
COPY --from=loader --chown=pharo:users /opt/pharo/Pharo.image ./

RUN mkdir logs

HEALTHCHECK CMD ./health-check.sh

CMD ["launchpad-start", "stargate-consul-example"]
