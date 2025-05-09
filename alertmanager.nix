{
  config,
  pkgs,
  ...
}: {
  services.prometheus.alertmanager = {
    enable = true;
    configuration = {
      receivers = [
        {
          name = "ntfy";
          # Your receiver configuration
        }
        # Other receivers
      ];
      # Rest of your AlertManager configuration
    };
  };
}
