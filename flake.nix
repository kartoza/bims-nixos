{
  description = "NixOS configuration";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs:
    with inputs; let
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets.json");

      nixpkgsWithOverlays = {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # DONE:: add any insecure packages you absolutely need here
          ];
        };
      };

      configurationDefaults = args: {
        nixpkgs = nixpkgsWithOverlays;
      };

      argDefaults = {
        inherit secrets inputs self;
        channels = {
        };
      };

      mkNixosConfiguration = {
        system ? "x86_64-linux",
        hostname,
        username,
        args ? {},
        modules,
      }: let
        specialArgs = argDefaults // {inherit hostname username;} // args;
      in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules =
            [
              (configurationDefaults specialArgs)
            ]
            ++ modules;
        };
    in {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

      nixosConfigurations.robot = mkNixosConfiguration {
        hostname = "bims";
        username = "bims"; # DONE: Set your preferred username here
        modules = [
          ./amd.nix
          disko.nixosModules.disko
          ./robot.nix
          ./linux.nix
          ./storage.nix
          ./grafana.nix
          ./loki-promtail.nix
          ./prometheus.nix
          ./grafana-dashboards.nix
        ];
      };
      
      systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false; 

      deploy = {
        sshUser = "root";
        user = "root";
        autoRollback = false;
        magicRollback = false;
        remoteBuild = true;
        nodes = {
          robot = {
            hostname = "37.27.227.42";
            profiles.system = {
              path = self.nixosConfigurations.robot;
            };
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      devShells.x86_64-linux.default = let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true; # needed for vscode
        };
      in
        pkgs.mkShell {
          packages = [
            pkgs.git
            pkgs.vim
            pkgs.jq
            pkgs.alejandra
            pkgs.vscode
          ];

          shellHook = ''
            echo " ----------------------------------------------------------------------------"
            echo "   BIMS Nixos Configuration"
            echo " ----------------------------------------------------------------------------"
            echo "✅ Dev shell for NixOS flake activated"
            echo "👀 nix flake show - show the contents of this flake"
            echo "🛠️ nixos-rebuild switch --flake .#robot --target-host root@37.27.227.42 --build-host root@37.27.227.42 --use-remote-sudo"
            echo "✏️ ./vscode.sh - launch vscode with the current flake"
            echo ""
            echo "🚧 Danger Zone:🚧"
            echo "   Destroy and completely reformat and reinstall the system"
            echo "   This will destroy all data on the target system!"
            echo "   Use with caution!"
            echo "   And it will not prompt you for confirmation!"
            echo "🚩 nix run github:numtide/nixos-anywhere -- --flake .#robot root@37.27.227.42"
            echo " ----------------------------------------------------------------------------"
          '';
        };
    };
}
