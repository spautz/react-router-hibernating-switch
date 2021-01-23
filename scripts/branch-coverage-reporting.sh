#!/usr/bin/env bash

# Fail if anything in here fails
set -e

# This script runs from the project root
cd "$(dirname "$0")/.."

source scripts/helpers.sh

###################################################################################################
# Setup: Node and node_packages should already have been set up in the environment init

run_command "./scripts/check-environment.sh"

###################################################################################################

CURRENT_BRANCH=$(git branch --show-current)

# If we're on the main branch, report code coverage separately for each project
if [ "${CURRENT_BRANCH}" = 'master' ] || true; then
  # Allow Coveralls to receive multiple reports from a single job
  export COVERALLS_PARALLEL=true

  for DIR in ./packages/*/; do
    DIR_IDENTIFIER=$(echo $DIR | sed -e 's/packages//gi' | sed -e 's/[^-a-z]//gi')
    COVERAGE_REPORTING_BRANCH="x-cov-${DIR_IDENTIFIER}"

    echo "setting GITHUB_REF=refs/heads/${COVERAGE_REPORTING_BRANCH}"
    export GITHUB_REF="refs/heads/${COVERAGE_REPORTING_BRANCH}"
    echo "setting GITHUB_HEAD_REF=refs/heads/${COVERAGE_REPORTING_BRANCH}"
    export GITHUB_HEAD_REF="refs/heads/${COVERAGE_REPORTING_BRANCH}"

    #export COVERALLS_SERVICE_JOB_ID="$(git rev-parse --short HEAD)-${COVERAGE_REPORTING_BRANCH}"
    export COVERALLS_GIT_BRANCH=$COVERAGE_REPORTING_BRANCH
    export TRAVIS_BRANCH=$COVERAGE_REPORTING_BRANCH
    run_command "yarn --cwd=${DIR} test:report-local"
  done
fi
