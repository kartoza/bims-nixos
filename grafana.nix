# FILE: monitoring/grafana.nix
{
  config,
  pkgs,
  ...
}: {
  services.grafana = {
    enable = true;
    settings.server = {
      http_addr = "127.0.0.1";
      http_port = 3000;
    };
    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        url = "http://localhost:9090";
        access = "proxy";
        isDefault = true;
      }
      {
        name = "Loki";
        type = "loki";
        url = "http://localhost:3100";
        access = "proxy";
      }
    ];
  };

  users.users.grafana.isSystemUser = true;
}
