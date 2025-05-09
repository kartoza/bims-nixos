# nixos-hetzner-robot-starter

This repository is intended to be a sane, batteries-included starter template
for running a LunarVim-powered remote NixOS development environment on a
Hetzner Robot dedicated server. It exists as a sister-project of
[nixos-wsl-starter](https://github.com/lgug2z/nixos-wsl-starter) and
[nixos-hetzner-cloud-starter](https://github.com/lgug2z/nixos-hetzner-cloud-starter).

If you don't want to dig into NixOS too much right now, the only file you need
to concern yourself with is [home.nix](home.nix). This is where you can add and
remove binaries to your global `$PATH`.

Go to [https://search.nixos.org](https://search.nixos.org/packages) to find the
correct package names, though usually they will be what you expect them to be
in other package managers.

`unstable-packages` is for packages that you want to always keep at the latest
released versions, and `stable-packages` is for packages that you want to track
with the current release of NixOS (currently 23.11).

If you want to update the versions of the available `unstable-packages`, run
`nix flake update` to pull the latest version of the Nixpkgs repository and
then apply the changes.

Make sure to look at all the `FIXME` notices in the various files which are
intended to direct you to places where you may want to make configuration
tweaks.

If you found this starter template useful, please consider
[sponsoring](https://github.com/sponsors/LGUG2Z) and [subscribing to my YouTube
channel](https://www.youtube.com/channel/UCeai3-do-9O4MNy9_xjO6mg?sub_confirmation=1).

## What Is Included

This starter is a lightly-opinionated take on a productive terminal-driven
development environment based on my own preferences. However, it is trivial to
customize to your liking both by removing and adding tools that you prefer.

* The default editor is `lvim`
* The default shell is `zsh`
* `docker` is enabled by default
* The prompt is [Starship](https://starship.rs/)
* [`fzf`](https://github.com/junegunn/fzf),
  [`lsd`](https://github.com/lsd-rs/lsd),
  [`zoxide`](https://github.com/ajeetdsouza/zoxide), and
  [`broot`](https://github.com/Canop/broot) are integrated into `zsh` by
  default
    * These can all be disabled easily by setting `enable = false` in
      [home.nix](home.nix), or just removing the lines all together
* [`direnv`](https://github.com/direnv/direnv) is integrated into `zsh` by
  default
* `git` config is generated in [home.nix](home.nix) with options provided to
  enable private HTTPS clones with secret tokens
* `zsh` config is generated in [home.nix](home.nix) and includes git aliases,
  useful WSL aliases, and
  [sensible`$WORDCHARS`](https://lgug2z.com/articles/sensible-wordchars-for-most-developers/)

## Quickstart

[![Watch the walkthrough video](https://img.youtube.com/vi/nlX8g0NXW1M/hqdefault.jpg)](https://www.youtube.com/watch?v=nlX8g0NXW1M)

* Order a server on Hetzner Robot
    * For this tutorial, I am using an [AX41-NVMe](https://www.hetzner.com/dedicated-rootserver/ax41-nvme)
    * The `disk-config.nix` file sets software RAID 1 on the 2x 512GB NVMe SSDs (just as the delivered server has)
* Set your SSH public key in `robot.nix` and `linux.nix`
* Go through all the `FIXME:` notices in this repo and make changes wherever
  you want
* Make sure you have activated the [Hetzner Rescue System](https://docs.hetzner.com/robot/dedicated-server/troubleshooting/hetzner-rescue-system/) by enabling it and then doing an automated hardware reset on the Robot web console
* Run [`nixos-anywhere`](https://github.com/nix-community/nixos-anywhere)
  against `root@<server-ip-address>`
```bash
nix run github:numtide/nixos-anywhere -- --flake .#robot root@<server-ip-address>
```
* Wait for the installation to complete
* Try to SSH into the server with `ssh <your-username-selected-in-flake.nix>@<server-ip-address>`
* You'll probably receive an error like the one below; follow the steps to remove the ip address from `known_hosts`
```
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.
Please contact your system administrator.
Add correct host key in ~/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in ~/.ssh/known_hosts:6
  remove with:
  ssh-keygen -f ~/.ssh/known_hosts" -R "<ip addrress>"
Host key for <ip_address> has changed and you have requested strict checking.
Host key verification failed.
```
* Now you can SSH into the server
* In a local terminal window, you can apply updated configurations to the remote server

There are two ways to do this:

### Directly on the server
```bash
sudo nixos-rebuild switch --flake ~/bims-nixos#robot
```

### From a remote client that has Nix available

🚩 Note: Currently only works if you have the same system architecture as the server.

```bash
nixos-rebuild switch --flake .#robot --target-host root@37.27.227.42 --build-host root@37.27.227.42 --use-remote-sudo
```

## Project Layout

In order to keep the template as approachable as possible for new NixOS users,
this project uses a flat layout without any nesting or modularization.

* `flake.nix` is where dependencies are specified
    * `nixpkgs` is the current release of NixOS
    * `disko` is used to prepare VM storage for NixOS
* `robot.nix` is where OpenSSH is configured and where the `root` SSH public
  key is set
* `linux.nix` is where the server is configured
    * The hostname is set here
    * The default shell is set here
    * User groups are set here
    * NixOS options are set here


```mermaid
graph TD
  subgraph Monitoring Stack

    Prometheus["🟦 Prometheus"]
    Grafana["🟩 Grafana"]
    Loki["🟪 Loki"]
    Promtail["📄 Promtail"]
    NodeExporter["🔧 node_exporter"]
    DockerExporter["🐳 docker_exporter"]
    Alertmanager["🚨 Alertmanager"]
    Nginx["🌐 Nginx Reverse Proxy"]
    ntfy["📬 ntfy.sh"]

  end

  NodeExporter --> Prometheus
  DockerExporter --> Prometheus
  Loki --> Prometheus
  Promtail --> Loki

  Prometheus --> Alertmanager
  Alertmanager --> ntfy

  Prometheus --> Grafana
  Loki --> Grafana

  Grafana --> Nginx
```


## Hetzner Storage Box Setup with SSH Key Authentication on NixOS

This guide explains how to configure a Hetzner Storage Box to allow SSH access from a NixOS server using a securely stored private key at `/etc/keys/id_storagebox`.

---

### 1. Generate SSH Key

Run these commands on your NixOS server:

```bash
sudo mkdir -p /etc/keys
sudo ssh-keygen -t rsa -b 4096 -f /etc/keys/id_storagebox -N ""
sudo chmod 600 /etc/keys/id_storagebox
sudo chown root:root /etc/keys/id_storagebox
```

### 2. Upload Public Key to Storage Box

Hetzner requires a special method to install the SSH key using port 23 and a built-in helper.

Replace uXXXXX with your actual Storage Box ID:

```
cat /etc/keys/id_storagebox.pub | ssh -p 23 uXXXXX@uXXXXX.your-storagebox.de install-ssh-key
```

Do this from any other clients that need access to the storage box too (e.g. to mirror the backups locally using restic)

