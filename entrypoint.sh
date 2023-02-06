#!/bin/sh -l

RESTART_INDIVIDUAL_RESOURCES=$1

if [ "$RESTART_INDIVIDUAL_RESOURCES" = true ] ; then
    echo "Will restart individual resources"
else
    echo "Will restart the whole server"
fi

SERVER_IP=$2
SERVER_PORT=$3
RCON_PASSWORD=$4
RESOURCES_FOLDER=$5

echo "$1"
echo "$2"
echo "$3"
echo "$4"
echo "$5"

git config --global --add safe.directory /github/workspace

if [ ${GITHUB_BASE_REF} ]; then
    # Pull Request
    git fetch origin ${GITHUB_BASE_REF} --depth=1
    export DIFF=$( git diff --name-only origin/${GITHUB_BASE_REF} ${GITHUB_SHA} )
    echo "Diff between origin/${GITHUB_BASE_REF} and ${GITHUB_SHA}"
else
    # Push
    git fetch origin ${GITHUB_EVENT_BEFORE} --depth=1
    export DIFF=$( git diff --name-only ${GITHUB_EVENT_BEFORE} ${GITHUB_SHA} )
    echo "Diff between ${GITHUB_EVENT_BEFORE} and ${GITHUB_SHA}"
fi

echo "${DIFF}" | while read -r changed; do
    echo $changed;
    echo "New line"
done
