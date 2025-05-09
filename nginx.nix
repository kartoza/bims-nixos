# FILE: monitoring/nginx-grafana-proxy.nix
{
  config,
  pkgs,
  lib,
  ...
}: let
  domain = "bims-mothership.kartoza.com";
in {
  environment.systemPackages = with pkgs; [nginx];

  networking.firewall.allowedTCPPorts = [80 443];

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
  };

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;

    # Existing docker proxy remains untouched
    locations."/" = {
      proxyPass = "http://127.0.0.1:63307";
      proxyWebsockets = true;
    };

    # Grafana on subpath
    locations."/grafana/" = {
      proxyPass = "http://127.0.0.1:3000/";
      proxyWebsockets = true;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "dimas@kartoza.com";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
  };
}
