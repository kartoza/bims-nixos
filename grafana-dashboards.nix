# FILE: monitoring/dashboards.nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Make sure dashboard JSON files exist in ./dashboards/ directory
  services.grafana = {
    provision = {
      # Alternative approach
      dashboards.path = "${pkgs.writeTextDir "dashboards.yaml" (builtins.toJSON {
        apiVersion = 1;
        providers = [
          {
            name = "default";
            orgId = 1;
            folder = "";
            type = "file";
            disableDeletion = false;
            updateIntervalSeconds = 10;
            allowUiUpdates = true;
            options = {
              path = "/var/lib/grafana/dashboards";
            };
          }
        ];
      })}";
    };
  };

  # Place dashboard json files in /etc/grafana/dashboards/
  environment.etc = {
    "grafana/dashboards/system-dashboard.json" = {
      source = ./system-dashboard.json;
      mode = "0644";
    };
  };

  # Create symlinks from Grafana's dashboard directory to our files
  systemd.tmpfiles.rules = [
    "d /var/lib/grafana/dashboards 0755 grafana grafana -"
    "L+ /var/lib/grafana/dashboards/system-dashboard.json - - - - /etc/grafana/dashboards/system-dashboard.json"
  ];
}
