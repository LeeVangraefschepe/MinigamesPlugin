FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# JDKs covering the Java versions Minecraft/Spigot has required over time:
#   Java 8  -> Minecraft up to 1.16.5
#   Java 17 -> Minecraft 1.17 - 1.20.4
#   Java 21 -> Minecraft 1.20.5 - 1.21.x
#   Java 25 -> anything newer (e.g. Mojang's post-1.21 year-based versioning)
# scripts/lib.sh maps a Minecraft version to one of these automatically.
#
# Installed from Eclipse Adoptium's own apt repo (not sdkman, not Ubuntu's
# jammy repos) because: sdkman's broker.sdkman.io gets blocked by some
# networks' TLS inspection, and Ubuntu 22.04 lags behind on brand-new Java
# majors. Adoptium ships new majors themselves, same day as each JDK GA.
# When Minecraft eventually needs a newer JDK than what's listed here, add
# another `temurin-<N>-jdk` line below and a matching entry in
# scripts/lib.sh's jdk_home_for_mc_version().
RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip \
        zip \
        maven \
        wget \
        gnupg \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO- https://packages.adoptium.net/artifactory/api/gpg/key/public > /etc/apt/keyrings/adoptium.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print $2}' /etc/os-release) main" > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        temurin-8-jdk \
        temurin-17-jdk \
        temurin-21-jdk \
        temurin-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Standard Adoptium apt package install locations, recorded for runtime
# scripts so they can point JAVA_HOME at the right one per Minecraft version.
RUN printf 'JDK8_HOME=/usr/lib/jvm/temurin-8-jdk-amd64\nJDK17_HOME=/usr/lib/jvm/temurin-17-jdk-amd64\nJDK21_HOME=/usr/lib/jvm/temurin-21-jdk-amd64\nJDK25_HOME=/usr/lib/jvm/temurin-25-jdk-amd64\n' \
        > /usr/local/etc/jdk-versions.env

RUN update-alternatives --set java /usr/lib/jvm/temurin-21-jdk-amd64/bin/java \
    && update-alternatives --set javac /usr/lib/jvm/temurin-21-jdk-amd64/bin/javac

# Pre-create the directories that devcontainer.json mounts as named volumes
# (.m2 cache, BuildTools cache) and own them as vscode. Otherwise Docker
# creates fresh volume mount points as root, and vscode can't write to them.
RUN mkdir -p /home/vscode/.m2 /home/vscode/.cache/spigot-buildtools \
    && chown -R vscode:vscode /home/vscode/.m2 /home/vscode/.cache

USER vscode
