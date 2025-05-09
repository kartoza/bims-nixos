{ config, pkgs, ... }:
{
  fileSystems."/storage-box" = {
    device = "u459835@u459835.your-storagebox.de:~/";
    fsType = "sshfs";
    options = [
      "StrictHostKeyChecking=accept-new"
      "user"
      "rw"
      "auto"
      "_netdev"
      "reconnect"
      "identityfile=/etc/keys/id_storagebox"
      "allow_other"
    ];
  };
}

