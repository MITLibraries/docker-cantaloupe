FROM uclalibrary/cantaloupe_dev

USER root

# Required for integration tests:
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends --no-upgrade \
      net-tools && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
