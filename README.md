# fivem-resource-watcher

fivem-resource-watcher GitHub Action allows you to restart resources automatically when changes are pushed.

## Features

- Detects change detection
- Restart only resources that have been changed
- Restart the whole server on changes
- Resource filters
- Works both on Linux and Windows

## Benefits
This allows you, as a server owner to have a Git Managed workflow for your server where you don't need to provide access to the VPS / Dedicated server or txAdmin console to your developers. They just push the changes to the git repository and they all get pulled and deployed automatically

## Inputs

| Input | Description | Required | Default |
| ------------ | ------------ | ------------ | ------------ |
| restartIndividualResources | Restart resources individually or restart the whole server | false | true |
| serverIP | IP of the FiveM server | true |  |
| serverPort | Port of the FiveM server | false | 30120 |
| resourcesFolder | Resources folder name | false | resources |
| resourcesToIgnore | List of resources that you want to ignore separated by spaces and not restart when changes are made to them | false | |
| restartServerWhen0Players | Restart the server instead when there are no players on the server. (Takes priority over `restartIndividualReesources`) | false | false |

## How to set up

Video Tutorial / Showcase: https://youtu.be/I_FqjKvcjxY

### Explanation
This action alone only does part of the automation. In order to actually make the restarts useful, we need to pull the remote changes first on the Server so that the changes are live after the restart. This doc will go through all the changes that you need to make in order to have a fully working pipeline. Your deployment workflow will look like the following after the pipeline is set up:

- You make the changes in your local clone of the repository
- You push the changes to the repository
- The pipeline will pull the changes that you just pushed, into your server automatically
- The pipeline will only restart the resources that you made changes to automatically, or it will restart the whole server depending on what you have configured

**Caution:** *The pipeline utilizes a protocol known as SSH to connect to your server and pull the changes. You should be aware of the risks involved if the SSH password leaks / is not too strong. Make sure to set a secure password for your user, or use SSH Keys instead.*

### Enabling RCON

The first thing that you need to do is enable RCON on your FiveM server.

- To do this, simply add the following to your `server.cfg` file:

```haproxy
rcon_password "somesecurepassword"
```
- then **change `somesecurepassword` to a secure passphrase.**
- Once done, restart your server

### Enabling SSH (Only for Windows)

This step is necessary only if you are using Windows. Linux users already have SSH enabled so this is not applicable to them.

If you are still reading this part then then you are using Windows and you need to install OpenSSH server on your VPS / Dedicated Server. To do that, follow these instructions:

- Connect / Login to your VPS / Dedicated server using RDP
- Open your browser and go to this link to download Win32-OpenSSH: https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.1.0.0p1-Beta/OpenSSH-Win64-v9.1.0.0.msi
- Install it by running the downloaded file
- Allow SSH connections through your firewall
	- To do this, open terminal / powershell as administrator, type the following and press enter:
		- `netsh advfirewall firewall add rule name="Open SSH Port 22" dir=in action=allow protocol=TCP localport=22 remoteip=any`
- Once done, you can test it out by opening a terminal / powershell on your local PC and type the following:

```bash
ssh <user>@<ip>
```

- Replace `<user>` with the username that you use to login to your RDP
- Replace `<ip>` with the IP of the VPS that you use to connect to your RDP
- Type in your password for the user when asked

- If everything was done correctly, you should see something like this on the terminal:

```powershell
Microsoft Windows [Version 10.0.20348.169]
(c) Microsoft Corporation. All rights reserved.

administrator@WIN-17A7N1QL3J3 C:\Users\Administrator>
```
- Type `exit` to disconnect from the SSH session


### Configuring secrets (VPS / Dedicated Server Only)

Now that everything is configured on the FiveM server as well as VPS / Dedicated Server, we need to setup some secrets in your GitHub repository that you're using for your server resources.

- Go to your repository, for example: https://github.com/iLLeniumTest/ServerResources
- Click on `Settings` from the top bar
- Click on `Secrets and variables` on the left navigation menu to expand it
- Then click on `Actions` to start setting up secrets

Following are the secrets that you need to configure in that section:

| Secret Name | Description |
| ------------ | ------------ |
| SSH_HOST | IP of your server which you use to login to your server (RDP or SSH) |
| SSH_PASSWORD  | Password for your user that you use to login to your server (RDP or SSH) (Not required when using SSH_KEY) |
| SSH_KEY | Set this in case you are using Key based authentication. (Not required when using SSH_PASSWORD)  |
| RCON_PASSWORD | Password that you have set in your server.cfg using `rcon_password` |

- For every secret mentioned in the table above, click on `New Repository Secret` and add it
- The `Name` field should have exactly the name of the secret from the table, for example `SSH_HOST`.
- The `Secret` field should have the value for the secret
- Make sure that you have set all of the secrets correctly before proceeding, or the pipeline will not work

**Note**: `SSH_PASSWORD` and `SSH_KEY` secrets are mutually exclusive, you must either set 1 or the other. There's no need to set them both.

### Configuring Pipeline (VPS / Dedicated Server only)

Now that we have configured the secrets as well, all that's left is to add the pipeline to your repository and change some of the parameters.

- Start by opening up the repository in Visual Studio Code or in your browser
- Create a new folder called `.github` in the root of your repository
- Create a subfolder called `workflows` in the `.github` folder that you just created
- Create a new file called `sync.yaml` in `.github/workflows` directory and paste the following contents into the file and save it:

```yaml
name: "Sync and Restart Resources"
on:
  push:
    branches:
      - main
jobs:
  sync-restart:
    runs-on: "ubuntu-latest"
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: "Pull remote changes"
        uses: appleboy/ssh-action@v0.1.7
        env:
          REPO_PATH: "C:/ServerResources"
        with:
          host: ${{ secrets.SSH_HOST }}
          username: Administrator
          #key: ${{ secrets.SSH_KEY }}
          password: ${{ secrets.SSH_PASSWORD }}
          port: 22
          script: |
            cd ${{ env.REPO_PATH }} && git pull
      - name: "Restart resources / server"
        uses: illeniumstudios/fivem-resource-watcher@main
        env:
          GITHUB_EVENT_BEFORE: ${{ github.event.before }}
        with:
          serverIP: ${{ secrets.SSH_HOST }}
          serverPort: 30120
          rconPassword: ${{ secrets.RCON_PASSWORD }}
          restartIndividualResources: false
```

There's a couple of things that you need to change before pushing this file:

1. On `Line 17` of the file, you need to set the folder path where you have cloned your repository on your remote VPS / Dedicated server. For example, if you are on Windows, it can be something like `C:/FiveM/MyRPServerResources`, or on Linux, it can be like `/home/username/FiveM/MyRPServerResources`.
2. On `Line 20`, set the username that you use for logging into your VPS / Dedicated Server via RDP
2. Comment out `Line 22` and uncomment `Line 21` if you're using an SSH key instead of a password for logging in.
3. On `Line 23`, set your SSH port if you have changed it explicitly. No need to do anything if you are using defaults.
4. Set your FiveM server port on `Line 32` if it is other than 30120
5. Change `restartIndividualResources` to `true` on `Line 34` if you want to restart the whole server after making changes. By default it is set to `false` which only restarts the individual resources that you have made changes to.

After making the above changes, save the file and push it to the repository.

And you're done. Now you should have a working pipeline that will automatically pull the changes on your remote server (VPS / Dedicated Server) if you push anything and will also restart the resources automatically for you.
