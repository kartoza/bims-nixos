{
  description = "NixOS configuration";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs:
    with inputs; let
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets.json");

      nixpkgsWithOverlays = with inputs; rec {
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
          # DONE: If your hardware is Intel, replace this with ./intel.nix
          ./amd.nix
          disko.nixosModules.disko
          ./robot.nix
          ./linux.nix
        ];
      };

      deploy = {
        sshUser = "root";
        user = "root";
        autoRollback = false;
        magicRollback = false;
        remoteBuild = true;
        nodes = {
          robot = {
            # DONE: Put the address of your Robot server here
            hostname = "37.27.227.42";
            profiles.system = {
              path = self.nixosConfigurations.robot;
            };
          };
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
