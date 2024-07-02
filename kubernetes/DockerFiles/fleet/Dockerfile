# Use an official Ubuntu base image
FROM ubuntu:20.04

# Set environment variables to avoid user interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y \
        curl \
        tar \
        sudo && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Elastic Agent, and create a directory for certs
RUN curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.14.1-linux-x86_64.tar.gz && \
    tar xzvf elastic-agent-8.14.1-linux-x86_64.tar.gz && \
    rm elastic-agent-8.14.1-linux-x86_64.tar.gz && \
    mkdir -p /elastic-agent-8.14.1-linux-x86_64/certs

# Set the working directory
WORKDIR /elastic-agent-8.14.1-linux-x86_64

# Expose the fleet server port
EXPOSE 8220

# Keep the container running
CMD ["tail", "-f", "/dev/null"]
