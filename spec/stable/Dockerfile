FROM uclalibrary/cantaloupe_stable

USER root

# Required for integration tests:
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends --no-upgrade \
      net-tools iproute2 && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
