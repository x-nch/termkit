#!/usr/bin/env bash
# profiles/minimal.sh — Shell configs only. No binary installs.
#
# Suitable for: shared servers, containers, restricted environments.

PROFILE_NAME="minimal"
PROFILE_DESC="Shell configs only — no tool installs"

profile_modules() {
    echo "shell git"
}
