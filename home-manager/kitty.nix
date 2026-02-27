{ ... }:

{
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    settings = {
      font_family = "JetBrains Mono";
      font_size = 14;
      tab_bar_edge = "top";
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      window_alert_on_bell = "no";
      enable_audio_bell = "no";
      strip_trailing_spaces = "smart";
      scrollback_lines = 10000;
      select_by_word_characters = "@-./_~?&=%+#:";
    };
    extraConfig = ''
      # Clic droit = coller depuis clipboard
      mouse_map right press ungrabbed paste_from_clipboard
      # Clic milieu = coller depuis primary selection
      mouse_map middle release ungrabbed paste_from_selection
      # Double clic = sélectionner mot
      mouse_map left doublepress ungrabbed select_word
      # Triple clic = sélectionner ligne
      mouse_map left triplepress ungrabbed select_line
      # Ctrl+clic = ouvrir URL
      mouse_map ctrl+left click ungrabbed open_selection
    '';
    keybindings = {
      "ctrl+alt+v" = "launch --location=hsplit";
      "ctrl+alt+h" = "launch --location=vsplit";
      "ctrl+shift+o" = "new_tab";
    };
  };
}
