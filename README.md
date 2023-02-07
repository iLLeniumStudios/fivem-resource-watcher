# fivem-resource-watcher

fivem-resource-watcher GitHub Action allows you to restart resources remotely via rcon.

## Features

- Detects change detection

- Restart only resources that have been changed

- Restart the whole server on changes

- Resource filters (Coming Soon)

## Inputs



This action alone only does part of the automation. In order to actually make the restarts useful, we need to pull the remote changes first on the Server so that the changes are live after the restart. This doc will go through all the changes that you need to make in order to have a fully working pipeline. You workflow will look like the following after the pipeline is set up:

- You make the changes in your local clone of the repository
- You push the changes to the repository
- The pipeline will pull the changes that you just pushed, into your server automatically
- The pipeline will only restart the resources that you made changes to automatically, or it will restart the whole server depending on what you have configured


## Inputs

## `who-to-greet`

**Required** The name of the person to greet. Default `"World"`.

## Outputs

## `time`

The time we greeted you.

## Example usage

uses: actions/hello-world-docker-action@v2
with:
  who-to-greet: 'Mona the Octocat'