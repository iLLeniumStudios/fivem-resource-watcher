#!/bin/sh -l

beginswith() { case $2 in "$1"*) true;; *) false;; esac; }

exists_in_array() {
  local element="$1"
  local array_str="$2"
  for i in $array_str; do
    if [ "$i" = "$element" ]; then
      return 0
    fi
  done
  return 1
}

is_array_empty() {
  local array_str="$1"
  [ -z "$array_str" ]
}

RESTART_INDIVIDUAL_RESOURCES=$1

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
    export DIFF=$( git diff --name-status ${GITHUB_EVENT_BEFORE} ${GITHUB_SHA} )
    echo "Diff between ${GITHUB_EVENT_BEFORE} and ${GITHUB_SHA}"
fi

resources_to_restart=

echo "${DIFF}" | while read -r changed; do
    STATUS=${changed:0:1}
    changed=${changed#??}
    if beginswith ${RESOURCES_FOLDER} "${changed}"; then
        filtered=${changed##*]/} # Remove subfolders
        filtered=${filtered%%/*} # Remove filename and get the folder which corresponds to the resource name
        if ! exists_in_array "$filtered" "$resources_to_restart"; then
            echo "Adding $filtered to resources that need to restart"
            resources_to_restart="$resources_to_restart $filtered"
        fi
    fi
done

if ! is_array_empty "$resources_to_restart"; then
    if [ "$RESTART_INDIVIDUAL_RESOURCES" = true ] ; then
        echo "Will restart individual resources"
        for resource in $resources_to_restart; do
            echo "Restarting ${resource}"
            #rcon -a ${SERVER_IP}:${SERVER_PORT} -p ${RCON_PASSWORD} command "ensure ${resource}"
        done
    else
        echo "Will restart the whole server"
       #rcon -a ${SERVER_IP}:${SERVER_PORT} -p ${RCON_PASSWORD} command 'quit "Restarting server"'
    fi
fi
