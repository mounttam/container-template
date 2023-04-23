# Use the official Ubuntu 20.04 base image
FROM --platform=linux/amd64 ubuntu:20.04

# Set environment variables
ENV PYTHON_VERSION=3.9
ENV GOLANG_VERSION=1.17

# Prevents prompts during package installations
ARG DEBIAN_FRONTEND=noninteractive

# Update the package list and install necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        ca-certificates \
        curl \
        cron \
        wget \
        build-essential \
        git \
        unzip \
        tzdata \
        vim

# Install Python
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils \
        python${PYTHON_VERSION}-venv \
        python3-pip

# Set Python as the default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install Golang
RUN wget -q https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm go${GOLANG_VERSION}.linux-amd64.tar.gz

# Set Go environment variables
ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash user

# Set the working directory
WORKDIR /home/user

# Install NOSCL
RUN mkdir -p .config/nostr
RUN go install github.com/fiatjaf/noscl@latest

#Change ownership of Home directory
RUN chown -R user /home/user

USER user

CMD ["bash"]
