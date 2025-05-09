# FILE: monitoring/dashboards.nix
{pkgs, ...}: {
  services.grafana.provision.dashboards = {
    enable = true;
    settings.providers = [
      {
        name = "default";
        options.path = "/etc/grafana/dashboards";
        type = "file";
        disableDeletion = false;
        editable = true;
      }
    ];
  };

  environment.etc."grafana/dashboards/docker.json".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/stefanprodan/dockprom/master/grafana/dashboards/Docker-Containers.json";
    sha256 = "1dyi7n0lmbvdmf2w2wrmcfihn90cqnygm36n31w6v8dnhimkfq0y";
  };

  environment.etc."grafana/dashboards/node-exporter.json".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rfrail3/grafana-dashboards/master/node-exporter-full.json";
    sha256 = "0qlxv7wv4lxv9m0xaznc1x1w4jzk61h0pk8v3iynwph2q92sfbxh";
  };

  environment.etc."grafana/dashboards/mdadm.json".source = pkgs.fetchurl {
    url = "https://gist.githubusercontent.com/timlinux/6fd4978e6ae1fca33c60f0e4ccad0ef3/raw/mdadm-grafana-dashboard.json";
    sha256 = "1fijvzq63xf2mklkz2m4r6rs2kgx4dxzvkqzz44flc2a9fyz1wbd";
  };

  environment.etc."grafana/dashboards/loki-logs.json".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/grafana/loki/main/production/grafana/dashboards/logs.json";
    sha256 = "0kvncd6mwy4d4xj6x0r9fn0ap2l75clhhqq6jxdhz5n4a0xqh7fv";
  };
}
