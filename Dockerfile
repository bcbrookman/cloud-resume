FROM mcr.microsoft.com/devcontainers/python:3.13@sha256:c237dacd6aa34e69e7c963b7b17555465f04409a968c49199dbc77573ac3bbdd

LABEL org.opencontainers.image.title="cloud-resume-cicd"
LABEL org.opencontainers.image.description="Development container for bcbrookman/cloud-resume"
LABEL org.opencontainers.image.source=https://github.com/bcbrookman/cloud-resume

# Dependency installation tasks are run individually to optimize for caching.
# Rebuilding should only be needed when dependencies change.

# Install Task
RUN \
 curl -L https://github.com/go-task/task/releases/download/v3.45.5/task_linux_amd64.tar.gz \
 | tar xvzf - \
 && mv task /usr/local/bin/

# Install pre-commit
RUN \
 --mount=source=./Taskfile.yaml,target=/mnt/tmp/Taskfile.yaml \
 cd /mnt/tmp/ \
 && task deps:pre-commit

# Install Azure CLI
RUN \
 --mount=source=./Taskfile.yaml,target=/mnt/tmp/Taskfile.yaml \
 cd /mnt/tmp/ \
 && task deps:azcli \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

# Install Pulumi CLI
COPY \
 --from=pulumi/pulumi-base:3.243.0@sha256:646f1c174dc014b6d2af885befb494b1798d7760d6a5b58ae69d8d0554293894 \
 /pulumi/bin/ /usr/local/bin/

# Install Python requirements
RUN \
 --mount=source=./Taskfile.yaml,target=/mnt/tmp/Taskfile.yaml \
 --mount=source=./app/api/requirements.txt,target=/mnt/tmp/app/api/requirements.txt \
 --mount=source=./app/api/requirements-dev.txt,target=/mnt/tmp/app/api/requirements-dev.txt \
 --mount=source=./infra/pulumi/requirements.txt,target=/mnt/tmp/infra/pulumi/requirements.txt \
 cd /mnt/tmp/ \
 && task deps:python
