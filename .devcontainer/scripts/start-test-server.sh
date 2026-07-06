#!/usr/bin/env bash
# Builds the plugin and launches a local Spigot test server for the version
# in minecraft-version.env, with the freshly built plugin jar dropped into
# its plugins/ folder.
#
# Usage: start-test-server.sh [minecraft-version] [--debug]
#   --debug suspends nothing but opens a JDWP port on 5005 so you can attach
#   a debugger (VS Code: Run and Debug -> "Attach to Spigot Server").
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"

DEBUG=false
POSITIONAL=()
for arg in "$@"; do
  case "${arg}" in
    --debug) DEBUG=true ;;
    *) POSITIONAL+=("${arg}") ;;
  esac
done

MC_VERSION="${POSITIONAL[0]:-$(load_mc_version)}"
export JAVA_HOME="$(jdk_home_for_mc_version "${MC_VERSION}")"
export PATH="${JAVA_HOME}/bin:${PATH}"

SERVER_DIR="${WORKSPACE_DIR}/server"
JAR="${SERVER_DIR}/spigot-${MC_VERSION}.jar"

if [ ! -f "${JAR}" ]; then
  echo "spigot-${MC_VERSION}.jar not found. Run: .devcontainer/scripts/build-spigot.sh ${MC_VERSION}" >&2
  exit 1
fi

echo "==> Building plugin (mvn package)"
mvn -q -f "${WORKSPACE_DIR}/pom.xml" -DskipTests package

mkdir -p "${SERVER_DIR}/plugins"
echo "eula=true" > "${SERVER_DIR}/eula.txt"

rm -f "${SERVER_DIR}"/plugins/*.jar
if compgen -G "${WORKSPACE_DIR}/target/*.jar" > /dev/null; then
  cp "${WORKSPACE_DIR}"/target/*.jar "${SERVER_DIR}/plugins/"
  echo "==> Copied built plugin jar(s) into server/plugins/"
else
  echo "==> WARNING: no jar found in target/ after build, server will start without the plugin" >&2
fi

cd "${SERVER_DIR}"

JAVA_ARGS=(-Xms1G -Xmx2G)
if [ "${DEBUG}" = true ]; then
  JAVA_ARGS+=("-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005")
  echo "==> Debug agent listening on port 5005 (attach with the 'Attach to Spigot Server' launch config)"
fi

echo "==> Starting Spigot ${MC_VERSION} with $(java -version 2>&1 | head -n1) (port 25565)"
exec java "${JAVA_ARGS[@]}" -jar "spigot-${MC_VERSION}.jar" nogui
