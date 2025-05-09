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
      server.http_listen_port = 3100;
      ingester.lifecycler.ring.kvstore.store = "inmemory";
      ingester.lifecycler.ring.replication_factor = 1;
      schema_config.configs = [
        {
          from = "2020-10-24";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";
          index = {
            prefix = "index_";
            period = "168h";
          };
        }
      ];
      storage_config = {
        boltdb_shipper.active_index_directory = "/var/lib/loki/index";
        boltdb_shipper.cache_location = "/var/lib/loki/cache";
        filesystem.directory = "/var/lib/loki/chunks";
      };
    };
  };

  services.promtail = {
    enable = true;
    configuration = {
      server.http_listen_port = 9080;
      clients = [{url = "http://localhost:3100/loki/api/v1/push";}];
      scrape_configs = [
        {
          job_name = "system";
          static_configs = [
            {
              targets = ["localhost"];
              labels = {
                job = "system";
                __path__ = "/var/log/**/*.log";
              };
            }
          ];
        }
        {
          job_name = "docker";
          static_configs = [
            {
              targets = ["localhost"];
              labels = {
                job = "docker";
                __path__ = "/var/lib/docker/containers/*/*.log";
              };
            }
          ];
        }
      ];
    };
  };
}
