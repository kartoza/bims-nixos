{
  imports = [
    ./disk-config.nix
  ];

  boot.loader.grub.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    extraConfig = ''
      PrintLastLog no
    '';
  };

  users.users.root.openssh.authorizedKeys.keys = [
    # DONE: Set your own public key here!
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICMP26uVkGW0ShtaKr3qW02rxdE5yDQp66D8+LP05B0y dimas@kartoza.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJm3ACcKCTZq0IcCB6pIXudFiW35/PfUQlMrX5DLrZ5H tim@kartoza.com"
  ];
}
