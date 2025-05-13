{ pkgs, ... }:

{
  imports = [
    ./disk-config.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
    zellij
    git
  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true; # Install GRUB to fallback path: EFI/BOOT/BOOTX64.EFI
    devices = [ "nodev" ];         # Avoids trying to install to MBR (BIOS mode)
  };

  boot.loader.efi.canTouchEfiVariables = false; # Don't attempt to write NVRAM entries

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 3000 ];
    allowedUDPPorts = [ ];
  };

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
