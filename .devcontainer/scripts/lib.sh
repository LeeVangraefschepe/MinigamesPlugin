#!/usr/bin/env bash
# Shared helpers sourced by the other scripts in this directory.
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_DIR="$(cd "${SCRIPTS_DIR}/.." && pwd)"
WORKSPACE_DIR="$(cd "${DEVCONTAINER_DIR}/.." && pwd)"
ENV_FILE="${DEVCONTAINER_DIR}/minecraft-version.env"

# Prints the version currently configured in minecraft-version.env
load_mc_version() {
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  echo "${MINECRAFT_VERSION}"
}

# Maps a Minecraft version to the JAVA_HOME needed to build/run it.
jdk_home_for_mc_version() {
  local v="$1"
  # shellcheck disable=SC1091
  source /usr/local/etc/jdk-versions.env
  case "${v}" in
    1.8*|1.9*|1.1[0-6]*)
      echo "${JDK8_HOME}"
      ;;
    1.17*|1.18*|1.19*|1.20.0|1.20.1|1.20.2|1.20.3|1.20.4)
      echo "${JDK17_HOME}"
      ;;
    1.20.5|1.20.6|1.21*)
      echo "${JDK21_HOME}"
      ;;
    *)
      # Anything outside the legacy 1.x scheme (e.g. Mojang's newer
      # year-based versioning such as 26.2) is assumed to need the newest
      # JDK available. If BuildTools reports it needs something even newer,
      # add a temurin-<N>-jdk package in the Dockerfile, a JDK<N>_HOME line
      # in jdk-versions.env, and a case here.
      echo "${JDK25_HOME}"
      ;;
  esac
}

# Derives a Bukkit/Spigot plugin.yml api-version (major.minor) from a full
# Minecraft version string, e.g. 1.21.1 -> 1.21, 1.20 -> 1.20.
api_version_for_mc_version() {
  local v="$1"
  local dots
  dots="$(grep -o '\.' <<< "${v}" | wc -l)"
  if [ "${dots}" -ge 2 ]; then
    echo "${v%.*}"
  else
    echo "${v}"
  fi
}
