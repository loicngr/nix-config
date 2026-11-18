{ config, ... }:

{
  programs.luciole = {
    enable = true;
    settings = {
      schema_version = 1;
      browser = {
        terminal_command = "kitty";
        thumbnail_cache_mib = 256;
      };
    };
  };

  # Conserve le fichier mimeapps.list personnel et ses autres associations.
  xdg.configFile."niri-mimeapps.list".text = ''
    [Default Applications]
    inode/directory=dev.noctalia.luciole.desktop;
    application/pdf=google-chrome.desktop;
  '';

  xdg.dataFile."dbus-1/services/org.freedesktop.FileManager1.service".source =
    "${config.programs.luciole.package}/share/dbus-1/services/dev.noctalia.luciole.FileManager1.service";
}
