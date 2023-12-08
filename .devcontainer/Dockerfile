# Python 3.10.0
# Debian 11 (bullseye)
# Microsoft ODBC Driver 18 for SQL Server
FROM mcr.microsoft.com/devcontainers/python:3.10-bullseye

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    lsb-release \
    shellcheck \
    vim \
    zsh

# Install Azure CLI latest (2.55.0)
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Microsoft ODBC Driver 18 for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc && \
    curl https://packages.microsoft.com/config/debian/11/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && ACCEPT_EULA=Y apt-get install -y \
    msodbcsql18 \
    mssql-tools18 \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> /etc/bash.bashrc && \
    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.zshrc && \
    echo 'alias ll='"'"'ls $LS_OPTIONS -al'"'"'' >> /etc/bash.bashrc && \
    echo 'alias ll='"'"'ls $LS_OPTIONS -al'"'"'' >> ~/.zshrc

# Install bicep
RUN az bicep install

ENV FLASK_APP=app.py

# Install Python requirements
RUN pip install --upgrade pip
COPY requirements.txt .
COPY requirements_dev.txt .
RUN python -m pip install -r ./requirements_dev.txt
