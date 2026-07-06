#!/usr/bin/env bash
# Switches the whole project to a different Minecraft version:
#   - updates minecraft-version.env
#   - updates pom.xml (spigot-api dependency version)
#   - updates plugin.yml (api-version)
#   - rebuilds Spigot for the new version via build-spigot.sh
#
# Usage: switch-version.sh <minecraft-version>   e.g. switch-version.sh 1.20.4
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"

NEW_VERSION="${1:?Usage: switch-version.sh <minecraft-version>, e.g. switch-version.sh 1.20.4}"
API_VERSION="$(api_version_for_mc_version "${NEW_VERSION}")"

sed -i "s/^MINECRAFT_VERSION=.*/MINECRAFT_VERSION=${NEW_VERSION}/" "${ENV_FILE}"

POM="${WORKSPACE_DIR}/pom.xml"
if [ -f "${POM}" ]; then
  sed -i "s#<minecraft.version>.*</minecraft.version>#<minecraft.version>${NEW_VERSION}</minecraft.version>#" "${POM}"
fi

PLUGIN_YML="${WORKSPACE_DIR}/src/main/resources/plugin.yml"
if [ -f "${PLUGIN_YML}" ]; then
  sed -i "s/^api-version:.*/api-version: '${API_VERSION}'/" "${PLUGIN_YML}"
fi

"${SCRIPT_DIR}/build-spigot.sh" "${NEW_VERSION}"

echo "==> Switched to Minecraft ${NEW_VERSION} (api-version ${API_VERSION})."
echo "    If VS Code doesn't pick up the new dependency, run:"
echo "    Ctrl/Cmd+Shift+P -> Java: Clean Java Language Server Workspace"
