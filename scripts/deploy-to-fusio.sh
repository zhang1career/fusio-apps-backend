#!/usr/bin/env bash
# Build the Fusio backend SPA and sync it into a Fusio PHP project, then patch index.html from .env.
#
# Usage:
#   ./scripts/deploy-to-fusio.sh /path/to/fusio
#   npm run sync:fusio -- /path/to/fusio
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_PROJECT="${1:-}"

if [[ -z "${TARGET_PROJECT}" ]]; then
  echo "Usage: $0 <target_project>" >&2
  echo "  npm:  npm run sync:fusio -- /path/to/fusio" >&2
  exit 1
fi

TARGET_PROJECT="$(cd "${TARGET_PROJECT}" && pwd)"
DEST="${TARGET_PROJECT}/public/apps/fusio"
ENV_FILE="${ROOT}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE} (copy from .env.example and adjust)." >&2
  exit 1
fi

if [[ ! -d "${TARGET_PROJECT}/public" ]]; then
  echo "Target does not look like a Fusio project (no public/): ${TARGET_PROJECT}" >&2
  exit 1
fi

echo "==> ng build (production)"
(cd "${ROOT}" && npm run build -- --configuration production)

echo "==> rsync -> ${DEST}"
mkdir -p "${DEST}"
rsync -av --delete "${ROOT}/dist/fusio/" "${DEST}/"

INDEX="${DEST}/index.html"
if [[ ! -f "${INDEX}" ]]; then
  echo "Expected index.html at ${INDEX}" >&2
  exit 1
fi

echo "==> patch ${INDEX} from .env"
python3 <<PY
import pathlib
import sys

root = pathlib.Path("${ROOT}")
target = pathlib.Path("${TARGET_PROJECT}")
env_path = root / ".env"
index_path = target / "public" / "apps" / "fusio" / "index.html"


def load_env(path):
    data = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        data[key] = value
    return data


env = load_env(env_path)
required = ("BASE_PATH", "API_URL", "APP_KEY")
missing = [k for k in required if k not in env or env[k] == ""]
if missing:
    sys.exit(f".env is missing or empty: {', '.join(missing)}")

text = index_path.read_text(encoding="utf-8")
replacements = {
    "\${BASE_PATH}": env["BASE_PATH"],
    "\${API_URL}": env["API_URL"],
    "\${APP_KEY}": env["APP_KEY"],
}
for needle, repl in replacements.items():
    if needle not in text:
        print(f"warning: placeholder not found in index.html: {needle}", file=sys.stderr)
    text = text.replace(needle, repl)

index_path.write_text(text, encoding="utf-8")
print("Patched:", index_path)
PY

echo "Done."
