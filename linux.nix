{
  # DONE: uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  # secrets,
  username,
  hostname,
  pkgs,
  inputs,
  ...
}: {
  # DONE: change to your tz! look it up with "timedatectl list-timezones"
  time.timeZone = "Europe/Lisbon";

  systemd.tmpfiles.rules = [
    "d /home/${username}/.config 0755 ${username} users"
    "d /home/${username}/.config/lvim 0755 ${username} users"
  ];

  networking.hostName = "${hostname}";


  environment.enableAllTerminfo = true;

  security.sudo.wheelNeedsPassword = false;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      # DONE: uncomment the next line if you want to run docker without sudo
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICMP26uVkGW0ShtaKr3qW02rxdE5yDQp66D8+LP05B0y dimas@kartoza.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJm3ACcKCTZq0IcCB6pIXudFiW35/PfUQlMrX5DLrZ5H tim@kartoza.com"
    ];
  };


  system.stateVersion = "24.11";

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  nix = {
    settings = {
      trusted-users = [username];
      accept-flake-config = true;
      auto-optimise-store = true;
    };

    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    package = pkgs.nixVersions.stable;
    extraOptions = ''experimental-features = nix-command flakes'';

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
}
