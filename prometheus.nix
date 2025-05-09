{
  config,
  pkgs,
  lib,
  ...
}: {
  services.prometheus = {
    enable = true;
    web.listenAddress = "127.0.0.1";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{targets = ["localhost:9100"];}];
      }
      {
        job_name = "docker";
        static_configs = [{targets = ["localhost:9323"];}];
      }
      {
        job_name = "loki";
        static_configs = [{targets = ["localhost:3100"];}];
      }
    ];
    alertmanagers = [{static_configs = [{targets = ["localhost:9093"];}];}];
    rules = [
      {
        groups = [
          {
            name = "default-alerts";
            rules = [
              {
                alert = "HighCPUUsage";
                expr = "100 - (avg by(instance)(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 90";
                for = "5m";
                labels.severity = "warning";
                annotations.description = "High CPU usage detected.";
              }
              {
                alert = "MDRaidDegraded";
                expr = "node_md_disks_required - node_md_disks_active > 0";
                for = "1m";
                labels.severity = "critical";
                annotations.description = "mdadm RAID degraded!";
              }
            ];
          }
        ];
      }
    ];
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      enableMdadm = true;
    };
    docker = {
      enable = true;
      listenAddress = "localhost";
      port = 9323;
    };
  };

  services.prometheus.alertmanager = {
    enable = true;
    webExternalUrl = "http://localhost:9093";
    configuration = {
      route.receiver = "ntfy";
      receivers = [
        {
          name = "ntfy";
          webhook_configs = [
            {
              url = "https://ntfy.sh/your-topic";
            }
          ];
        }
      ];
    };
  };

  users.users.prometheus.isSystemUser = true;
}
