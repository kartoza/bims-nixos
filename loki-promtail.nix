# FILE: monitoring/loki-promtail.nix
{
  config,
  pkgs,
  ...
}: {
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = 3100;
      };

      common = {
        path_prefix = "/var/lib/loki";
        storage = {
          filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/var/lib/loki/rules";
          };
        };
        replication_factor = 1;
        ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };

      schema_config = {
        configs = [
          {
            from = "2023-01-01";
            store = "boltdb-shipper";
            object_store = "filesystem";
            schema = "v12"; # Updated schema version
            index = {
              prefix = "index_";
              period = "24h"; # Set to 24h period as recommended
            };
          }
        ];
      };

      limits_config = {
        allow_structured_metadata = false; # Disable structured metadata until we upgrade to v13
      };

      ruler = {
        alertmanager_url = "http://localhost:9093";
        storage = {
          type = "local";
          local = {
            directory = "/var/lib/loki/rules";
          };
        };
        rule_path = "/var/lib/loki/rules";
        ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };

      compactor = {
        working_directory = "/var/lib/loki/compactor"; # Set working directory
        retention_enabled = true;
        compaction_interval = "5m";
      };

      analytics = {
        reporting_enabled = false;
      };
    };
  };

  # Promtail configuration
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/var/lib/promtail/positions.yaml";
      };
      clients = [
        {
          url = "http://localhost:3100/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "${config.networking.hostName}";
            };
          };
          relabel_configs = [
            {
              source_labels = ["__journal__systemd_unit"];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };

  # Create necessary directories
  systemd.tmpfiles.rules = [
    "d /var/lib/loki 0750 loki loki -"
    "d /var/lib/loki/chunks 0750 loki loki -"
    "d /var/lib/loki/rules 0750 loki loki -"
    "d /var/lib/loki/compactor 0750 loki loki -"
  ];
}
