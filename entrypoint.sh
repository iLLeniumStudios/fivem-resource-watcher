#!/bin/sh -l

beginswith() { case $2 in "$1"*) true ;; *) false ;; esac }

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

append_if_not_exists() {
  local element="$1"
  local array_str="$2"
  if exists_in_array "$element" "$array_str"; then
    echo "$array_str"
  else
    echo "$array_str $element"
  fi
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

git config --global --add safe.directory /github/workspace

if [ ${GITHUB_BASE_REF} ]; then
    # Pull Request
    git fetch origin ${GITHUB_BASE_REF} --depth=1
    export DIFF=$(git diff --name-only origin/${GITHUB_BASE_REF} ${GITHUB_SHA})
    echo "Diff between origin/${GITHUB_BASE_REF} and ${GITHUB_SHA}"
else
    # Push
    git fetch origin ${GITHUB_EVENT_BEFORE} --depth=1
    export DIFF=$(git diff --name-status ${GITHUB_EVENT_BEFORE} ${GITHUB_SHA})
    echo "Diff between ${GITHUB_EVENT_BEFORE} and ${GITHUB_SHA}"
fi

resources_to_restart=

IFS=$'\n'
for changed in $DIFF; do
    changed=${changed#??}
    if beginswith "${RESOURCES_FOLDER}" "${changed}"; then
        filtered=${changed##*]/} # Remove subfolders
        filtered=${filtered%%/*} # Remove filename and get the folder which corresponds to the resource name
        resources_to_restart="$(append_if_not_exists "$filtered" "$resources_to_restart")"
    fi
done
unset IFS

if ! is_array_empty "$resources_to_restart"; then
    if [ "$RESTART_INDIVIDUAL_RESOURCES" = true ]; then
        echo "Will restart individual resources"
        for resource in $resources_to_restart; do
            echo "Restarting ${resource}"
            rcon -a ${SERVER_IP}:${SERVER_PORT} -p ${RCON_PASSWORD} command "ensure ${resource}"
        done
    else
        echo "Will restart the whole server"
        rcon -a ${SERVER_IP}:${SERVER_PORT} -p ${RCON_PASSWORD} command 'quit "Restarting server"'
    fi
else
    echo "Nothing to restart"
fi
