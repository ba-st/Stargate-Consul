# Stage 1: Load the project
FROM basmalltalk/pharo:7.0-image AS loader
ARG TRAVIS_BRANCH=release-candidate
COPY load-project.st ./
RUN pharo Pharo.image load-project.st --save --quit

# Stage 2: Copy the resulting Pharo.image with our project loaded
# into a new docker image with just the vm
FROM basmalltalk/pharo:7.0

USER root

RUN apt-get update \
    && apt-get --assume-yes --no-install-recommends install curl \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/Stargate-Consul-Example-API
COPY start.sh .
COPY health-check.sh .
COPY --from=loader /opt/pharo/Pharo.image ./
COPY --from=loader /opt/pharo/Pharo.changes ./
COPY --from=loader /opt/pharo/Pharo*.sources ./

RUN mkdir logs \
  && chmod a+x start.sh \
  && chmod a+x health-check.sh \
  && chown --recursive pharo:pharo /opt/Stargate-Consul-Example-API

USER pharo
EXPOSE 8080

HEALTHCHECK CMD /opt/Stargate-Consul-Example-API/health-check.sh

CMD ["./start.sh"]
