#!/usr/bin/env bash
# Builds Spigot (via the official BuildTools) for a Minecraft version and
# installs spigot-api/spigot into the local Maven repo so the plugin project
# can resolve it as a normal dependency.
#
# Usage: build-spigot.sh [minecraft-version]
#   With no argument, uses the version from minecraft-version.env.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"

MC_VERSION="${1:-$(load_mc_version)}"
export JAVA_HOME="$(jdk_home_for_mc_version "${MC_VERSION}")"
export PATH="${JAVA_HOME}/bin:${PATH}"

echo "==> Building Spigot ${MC_VERSION} with $(java -version 2>&1 | head -n1)"

BUILDTOOLS_DIR="${HOME}/.cache/spigot-buildtools"
mkdir -p "${BUILDTOOLS_DIR}"
cd "${BUILDTOOLS_DIR}"

if [ ! -f BuildTools.jar ]; then
  echo "==> Downloading BuildTools.jar"
  curl -sSL -o BuildTools.jar "https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar"
fi

VERSION_OUT_DIR="${BUILDTOOLS_DIR}/${MC_VERSION}"
mkdir -p "${VERSION_OUT_DIR}"

# --compile-if-changed exits 2 (not 0) when nothing upstream has changed
# since the last build, as a deliberate "didn't rebuild" signal rather than
# a failure -- the artifacts from the prior successful build are still
# valid, so that's not fatal here. Any other non-zero exit is a real failure.
set +e
java -jar BuildTools.jar --rev "${MC_VERSION}" --output-dir "${VERSION_OUT_DIR}" --compile-if-changed
BUILDTOOLS_EXIT=$?
set -e
if [ "${BUILDTOOLS_EXIT}" -ne 0 ] && [ "${BUILDTOOLS_EXIT}" -ne 2 ]; then
  echo "BuildTools failed with exit code ${BUILDTOOLS_EXIT}" >&2
  exit "${BUILDTOOLS_EXIT}"
elif [ "${BUILDTOOLS_EXIT}" -eq 2 ]; then
  echo "==> No upstream changes since the last build; reusing existing artifacts."
fi

SERVER_DIR="${WORKSPACE_DIR}/server"
mkdir -p "${SERVER_DIR}"
cp "${VERSION_OUT_DIR}/spigot-${MC_VERSION}.jar" "${SERVER_DIR}/spigot-${MC_VERSION}.jar"
ln -sf "spigot-${MC_VERSION}.jar" "${SERVER_DIR}/spigot.jar"

echo "==> Done."
echo "    spigot-api ${MC_VERSION}-R0.1-SNAPSHOT installed to ~/.m2"
echo "    Test server jar: server/spigot-${MC_VERSION}.jar"
