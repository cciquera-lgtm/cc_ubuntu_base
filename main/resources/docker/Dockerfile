FROM ubuntu:latest

# Install Packages
RUN apt-get clean && \
    apt-get update && \
    apt-get upgrade --yes --no-install-recommends --auto-remove && \
    apt-get install --yes --no-install-recommends --auto-remove \
        ca-certificates \
        openssl \
        bc \
        lsof

# Copy scripts and packages to container
COPY    scripts   /local/scripts/
COPY    packages  /local/packages/

# Install / Configure NCPA
WORKDIR /local/scripts/ncpa/bin
RUN ./setup_ncpa.sh ; rm -f /local/packages/*
