#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
containerlab destroy -t topology.secure.clab.yml --cleanup
