# FILE: monitoring/dashboards.nix
{
  config,
  pkgs,
  ...
}: {
  services.grafana = {
    settings = {
      server = {
        # Any server settings here
      };
    };

    provision = {
      # New structure for provisioning dashboards
      dashboards = {
        settings = [
          {
            name = "default";
            orgId = 1;
            folder = "Dashboards";
            type = "file";
            disableDeletion = false;
            updateIntervalSeconds = 10;
            allowUiUpdates = true;
            options = {
              path = "/var/lib/grafana/dashboards";
            };
          }
        ];
      };
    };
  };

  # Then ensure your dashboard files are placed in the correct location
  environment.etc = {
    "grafana/dashboards/system-dashboard.json" = {
      source = ./dashboards/system-dashboard.json;
      mode = "0644";
      user = "grafana";
      group = "grafana";
    };
    # Add other dashboards as needed
  };

  # Create the directory for storing dashboards
  systemd.tmpfiles.rules = [
    "d /var/lib/grafana/dashboards 0755 grafana grafana -"
    "L+ /var/lib/grafana/dashboards/system-dashboard.json - - - - /etc/grafana/dashboards/system-dashboard.json"
    # Add symlinks for other dashboards
  ];
}
