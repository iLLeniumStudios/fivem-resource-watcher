#!/bin/sh -l

echo "$1"
echo "$2"
echo "$3"
echo "$4"
echo "$5"

if [ ${GITHUB_BASE_REF} ]; then
    # Pull Request
    git fetch origin ${GITHUB_BASE_REF} --depth=1
    export DIFF=$( git diff --name-only origin/${GITHUB_BASE_REF} ${GITHUB_SHA} )
    echo "Diff between origin/${GITHUB_BASE_REF} and ${GITHUB_SHA}"
else
    # Push
    git fetch origin ${GITHUB_EVENT_BEFORE} --depth=1
    export DIFF=$( git diff --name-only ${GITHUB_EVENT_BEFORE} ${GITHUB_SHA} )
    echo $DIFF
    echo "Diff between ${GITHUB_EVENT_BEFORE} and ${GITHUB_SHA}"
fi

echo "${DIFF}"
