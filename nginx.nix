{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ nginx ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts."bims-mothership.kartoza.com" = {
      forceSSL = true;
      enableACME = true;

      # Proxy to the container's HTTP port
      locations."/" = {
        proxyPass = "http://127.0.0.1:63307";
        proxyWebsockets = true;
      };
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
