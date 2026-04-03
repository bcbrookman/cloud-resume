FROM mcr.microsoft.com/devcontainers/python:3.14

LABEL org.opencontainers.image.title="cloud-resume-cicd"
LABEL org.opencontainers.image.description="Development container for bcbrookman/cloud-resume"
LABEL org.opencontainers.image.source=https://github.com/bcbrookman/cloud-resume

# Dependency installation tasks are run individually to optimize for caching.
# Rebuilding should only be needed when dependencies change.

# Install Task
RUN curl -L https://github.com/go-task/task/releases/download/v3.45.5/task_linux_amd64.tar.gz \
 | tar xvzf - \
 && mv task /usr/local/bin/

# Install pre-commit
RUN --mount=source=./Taskfile.yaml,target=/mnt/tmp/Taskfile.yaml \
 cd /mnt/tmp/ \
 && task deps:pre-commit

# Install Azure CLI
RUN --mount=source=./Taskfile.yaml,target=/mnt/tmp/Taskfile.yaml \
 cd /mnt/tmp/ \
 && task deps:azcli \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

# Install Python requirements
RUN --mount=source=./Taskfile.yaml,target=/mnt/tmp/Taskfile.yaml \
 --mount=source=./app/api/requirements.txt,target=/mnt/tmp/app/api/requirements.txt \
 --mount=source=./app/api/requirements-dev.txt,target=/mnt/tmp/app/api/requirements-dev.txt \
 cd /mnt/tmp/ \
 && task deps:python
