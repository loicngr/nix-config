{ pkgs, unstable, ... }:

{
  imports = [
    ./kitty.nix
    ./niri.nix
  ];
  home.username = "loicngr";
  home.homeDirectory = "/home/loicngr";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  home.packages = with pkgs; [
    # Ai
    claude-code
    codex
    # unstable.ollama-cuda

    # Games
    prismlauncher
    mangohud
    (heroic.override {
      extraPkgs = pkgs: [
        gamescope
        gamemode
      ];
    })
    umu-launcher

    # Tools
    cordova
    gradle
    # cudatoolkit
    bun
    uv

    # Applications
    fastfetch
    keepassxc
    wkhtmltopdf
    gradia
    element-desktop
    libreoffice

    # Kubernetes & Docker
    k9s
    kubectl
    kubernetes-helm
    minikube

    # Niri - Wayland compositor + Noctalia
    brightnessctl
    kanshi
    solaar
    catppuccin-gtk
    catppuccin-cursors.mochaMauve
    papirus-icon-theme

    # GNOME
    gnome-tweaks
    gnomeExtensions.dash-to-panel
    gnomeExtensions.appindicator
    gnomeExtensions.clipboard-indicator
    # gnomeExtensions.forge
    # gnomeExtensions.auto-move-windows

    gnomeExtensions.one-thing

    # Éditeurs & IDE
    unstable.jetbrains.phpstorm
    android-studio

    (pkgs.writeShellScriptBin "eslint-wrapper" (builtins.readFile ../scripts/eslint-wrapper.sh))
    (pkgs.writeShellScriptBin "php-cs-fixer-wrapper" (
      builtins.readFile ../scripts/php-cs-fixer-wrapper.sh
    ))
    (pkgs.writeShellScriptBin "phpstan-wrapper" (builtins.readFile ../scripts/phpstan-wrapper.sh))
    (pkgs.writeShellScriptBin "phpunit-run" (builtins.readFile ../scripts/phpunit-run.sh))
    (pkgs.writeShellScriptBin "claude-merge" (builtins.readFile ../scripts/claude-merge.sh))
    (pkgs.writeShellScriptBin "claude-commit" (builtins.readFile ../scripts/claude-commit.sh))
    (pkgs.writeShellScriptBin "tmux-project" (builtins.readFile ../scripts/tmux-project.sh))
  ];

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "Dracula";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "loicngr";
      user.email = "loicnogier@ik.me";
      core.editor = "micro";
      init.defaultBranch = "main";
      pull.rebase = true;
      merge.conflictstyle = "diff3";
      rerere.enabled = true;
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

  programs.lazygit = {
    enable = true;
    package = unstable.lazygit;
    settings = {
      gui.language = "fr";
      customCommands = [
        {
          key = "C";
          description = "Générer un message de commit avec Claude Code";
          context = "files";
          loadingText = "Génération du message de commit...";
          command = "claude-commit";
        }
        {
          key = "M";
          description = "Merge --no-ff --no-commit avec résolution Claude";
          context = "localBranches";
          output = "terminal";
          prompts = [
            {
              type = "input";
              title = "Branche à merger";
              key = "Branch";
            }
          ];
          command = "claude-merge {{.Form.Branch}}";
        }
      ];
    };
  };

  programs.bat = {
    enable = true;
    themes = {
      catppuccin-mocha = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
          hash = "sha256-OFTHrrBeFw/dGlGTHp2hKIz7pUbf9g2yMLkQTvDWk5o=";
          sparseCheckout = [
            "themes/Catppuccin Mocha.tmTheme"
          ];
        };
      };
    };
    config = {
      theme = "Catppuccin Mocha";
      style = "plain";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    # Utiliser fd au lieu de find (plus rapide, respecte .gitignore)
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";

    # Options par défaut
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline"
      "--margin=1"
      "--padding=1"
      # Catppuccin Mocha
      "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    ];

    # Ctrl+T : recherche fichiers
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}'"
    ];

    # Alt+C : cd dans un répertoire
    changeDirWidgetOptions = [
      "--preview 'eza --tree --color=always --icons --level=2 {}'"
    ];

    # Ctrl+R : historique (déjà configuré par défaut)
    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };

  programs.eza = {
    enable = true;
    colors = "auto";
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = false;
    extraOptions = [
      "--group-directories-first"
    ];
    git = true;
    icons = "always";
    theme = {
      catppuccin = ''
                colourful: true

                filekinds:
                  normal: {foreground: "#BAC2DE"}
                  directory: {foreground: "#89B4FA"}
                  symlink: {foreground: "#89DCEB"}
                  pipe: {foreground: "#7F849C"}
                  block_device: {foreground: "#EBA0AC"}
                  char_device: {foreground: "#EBA0AC"}
                  socket: {foreground: "#585B70"}
                  special: {foreground: "#CBA6F7"}
                  executable: {foreground: "#A6E3A1"}
                  mount_point: {foreground: "#74C7EC"}

                perms:
                  user_read: {foreground: "#CDD6F4"}
                  user_write: {foreground: "#F9E2AF"}
                  user_execute_file: {foreground: "#A6E3A1"}
                  user_execute_other: {foreground: "#A6E3A1"}
                  group_read: {foreground: "#BAC2DE"}
                  group_write: {foreground: "#F9E2AF"}
                  group_execute: {foreground: "#A6E3A1"}
                  other_read: {foreground: "#A6ADC8"}
                  other_write: {foreground: "#F9E2AF"}
                  other_execute: {foreground: "#A6E3A1"}
                  special_user_file: {foreground: "#CBA6F7"}
                  special_other: {foreground: "#585B70"}
                  attribute: {foreground: "#A6ADC8"}

                size:
                  major: {foreground: "#A6ADC8"}
                  minor: {foreground: "#89DCEB"}
                  number_byte: {foreground: "#CDD6F4"}
                  number_kilo: {foreground: "#BAC2DE"}
                  number_mega: {foreground: "#89B4FA"}
                  number_giga: {foreground: "#CBA6F7"}
                  number_huge: {foreground: "#CBA6F7"}
                  unit_byte: {foreground: "#A6ADC8"}
                  unit_kilo: {foreground: "#89B4FA"}
                  unit_mega: {foreground: "#CBA6F7"}
                  unit_giga: {foreground: "#CBA6F7"}
                  unit_huge: {foreground: "#74C7EC"}

                users:
                  user_you: {foreground: "#CDD6F4"}
                  user_root: {foreground: "#F38BA8"}
                  user_other: {foreground: "#CBA6F7"}
                  group_yours: {foreground: "#BAC2DE"}
                  group_other: {foreground: "#7F849C"}
                  group_root: {foreground: "#F38BA8"}

                links:
                  normal: {foreground: "#89DCEB"}
                  multi_link_file: {foreground: "#74C7EC"}

                git:
                  new: {foreground: "#A6E3A1"}
                  modified: {foreground: "#F9E2AF"}
                  deleted: {foreground: "#F38BA8"}
                  renamed: {foreground: "#94E2D5"}
                  typechange: {foreground: "#F5C2E7"}
                  ignored: {foreground: "#7F849C"}
                  conflicted: {foreground: "#EBA0AC"}

                git_repo:
                  branch_main: {foreground: "#CDD6F4"}
                  branch_other: {foreground: "#CBA6F7"}
                  git_clean: {foreground: "#A6E3A1"}
                  git_dirty: {foreground: "#F38BA8"}

                security_context:
                  colon: {foreground: "#7F849C"}
                  user: {foreground: "#BAC2DE"}
                  role: {foreground: "#CBA6F7"}
                  typ: {foreground: "#585B70"}
                  range: {foreground: "#CBA6F7"}

                file_type:
                  image: {foreground: "#F9E2AF"}
                  video: {foreground: "#F38BA8"}
                  music: {foreground: "#A6E3A1"}
                  lossless: {foreground: "#94E2D5"}
                  crypto: {foreground: "#585B70"}
                  document: {foreground: "#CDD6F4"}
                  compressed: {foreground: "#F5C2E7"}
                  temp: {foreground: "#EBA0AC"}
                  compiled: {foreground: "#74C7EC"}
                  build: {foreground: "#585B70"}
                  source: {foreground: "#89B4FA"}

                punctuation: {foreground: "#7F849C"}
                date: {foreground: "#F9E2AF"}
                inode: {foreground: "#A6ADC8"}
                blocks: {foreground: "#9399B2"}
                header: {foreground: "#CDD6F4"}
                octal: {foreground: "#94E2D5"}
                flags: {foreground: "#CBA6F7"}

                symlink_path: {foreground: "#89DCEB"}
                control_char: {foreground: "#74C7EC"}
                broken_symlink: {foreground: "#F38BA8"}
                broken_path_overlay: {foreground: "#585B70"}
        	  '';
    };
  };

  programs.tmux = {
    enable = true;

    # Prefix : Ctrl+a (plus ergonomique que Ctrl+b)
    prefix = "C-a";

    # Options de base
    mouse = true;
    keyMode = "vi";
    baseIndex = 1; # Fenêtres commencent à 1
    escapeTime = 0; # Pas de délai pour Escape
    historyLimit = 50000;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      # Sauvegarde/restauration de sessions
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      # Copier dans le clipboard système
      yank
      # Sélection rapide d'URLs, IPs, hashs, paths
      {
        plugin = fingers;
        extraConfig = ''
          set -g @fingers-key f
        '';
      }
      # Gestion sessions/windows/panes avec fzf
      {
        plugin = tmux-fzf;
        extraConfig = ''
          set -g @tmux-fzf-launch-key F
        '';
      }
      # Thème catppuccin
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -g @catppuccin_window_status_style 'rounded'
        '';
      }
    ];

    extraConfig = ''
      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Transmettre les focus events aux applications
      set -g focus-events on

      # Renuméroter les fenêtres automatiquement
      set -g renumber-windows on

      # Panes commencent à 1 (comme les fenêtres)
      set -g pane-base-index 1

      # Clipboard OSC 52
      set -g set-clipboard on
      set -g allow-passthrough on

      # Split avec h (horizontal) et v (vertical)
      bind h split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"

      # Nouvelle fenêtre dans le même répertoire
      bind c new-window -c "#{pane_current_path}"

      # Reload config avec r
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config rechargée!"

      # Resize panes avec Ctrl+flèches
      bind -r C-Left resize-pane -L 5
      bind -r C-Right resize-pane -R 5
      bind -r C-Up resize-pane -U 5
      bind -r C-Down resize-pane -D 5

      # Vi-style copy mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"

      # Renommer fenêtre/session
      bind n command-prompt "rename-window '%%'"
      bind N command-prompt "rename-session '%%'"

      # Floating popup scratch terminal (Alt+g)
      bind -n M-g if-shell -F '#{==:#{session_name},scratch}' {
        detach-client
      } {
        display-popup -d "#{pane_current_path}" -xC -yC -w 80% -h 75% -E 'tmux new-session -A -s scratch'
      }
    '';
  };

  # GNOME dconf settings
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "kitty";
      binding = "<Super>t";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Chrome";
      command = "google-chrome-stable";
      binding = "<Super>b";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "Gradia";
      command = "gradia --screenshot=INTERACTIVE";
      binding = "<Shift><Super>S";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      name = "Gradia Impr";
      command = "gradia --screenshot=INTERACTIVE";
      binding = "Print";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      name = "Nautilus";
      command = "nautilus";
      binding = "<Super>n";
    };

    # Activer les extensions GNOME
    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "clipboard-indicator@tudmotu.com"
        # "forge@jmmaranan.com"
        "dash-to-panel@jderose9.github.com"
        # "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "one-thing@github.com"
      ];
    };

    # # Dash to Panel - barre en haut sur tous les écrans
    # "org/gnome/shell/extensions/dash-to-panel" = {
    #   animate-app-switch = false;
    #   animate-appicon-hover-animation-extent = "{'RIPPLE': 4, 'PLANK': 4, 'SIMPLE': 1}";
    #   animate-window-launch = false;
    #   appicon-style = "NORMAL";
    #   context-menu-entries = "[]";
    #   dot-position = "BOTTOM";
    #   group-apps = true;
    #   highlight-appicon-hover = false;
    #   hotkeys-overlay-combo = "TEMPORARILY";
    #   isolate-monitors = true;
    #   isolate-monitors-with-single-panel = false;
    #   isolate-workspaces = true;
    #   panel-anchors = ''{"BOE-0x00000000":"MIDDLE","SAM-H4LTB01542":"MIDDLE","DEL-5K4MY63S270U":"MIDDLE"}'';
    #   panel-element-positions = ''{"SAM-H4LTB01542":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":true,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":false,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"centerMonitor"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}],"DEL-5K4MY63S270U":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":true,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":false,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"centerMonitor"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}'';
    #   panel-lengths = ''{"SAM-H4LTB01542":100,"DEL-5K4MY63S270U":100}'';
    #   panel-positions = ''{"SAM-H4LTB01542":"TOP","DEL-5K4MY63S270U":"TOP"}'';
    #   panel-sizes = ''{"SAM-H4LTB01542":32,"DEL-5K4MY63S270U":32}'';
    #   progress-show-count = true;
    #   show-apps-icon-file = "";
    #   show-favorites = false;
    #   show-favorites-all-monitors = false;
    #   show-running-apps = false;
    #   show-tooltip = false;
    #   show-window-previews = false;
    #   stockgs-keep-dash = false;
    #   stockgs-keep-top-panel = false;
    #   stockgs-panelbtn-click-only = false;
    #   taskbar-locked = true;
    #   trans-use-custom-gradient = false;
    #   trans-use-custom-opacity = true;
    #   trans-panel-opacity = 0.7;
    #   hide-overview-on-startup = true;
    #   window-preview-title-position = "TOP";
    # };

    # # Auto Move Windows - assigner les applications aux workspaces
    # "org/gnome/shell/extensions/auto-move-windows" = {
    #   application-list = [
    #     "element-desktop.desktop:7"
    #     "org.keepassxc.KeePassXC.desktop:6"
    #     "thunderbird.desktop:8"
    #   ];
    # };

    # One Thing - afficher une tâche dans la barre
    "org/gnome/shell/extensions/one-thing" = {
      hot-key = false;
      location-in-status-bar = 1;
      thing-value = "Task";
    };

    # Désactiver les raccourcis Super+1-9 pour lancer les apps favorites
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [ "disabled" ];
      switch-to-application-2 = [ "disabled" ];
      switch-to-application-3 = [ "disabled" ];
      switch-to-application-4 = [ "disabled" ];
      switch-to-application-5 = [ "disabled" ];
      switch-to-application-6 = [ "disabled" ];
      switch-to-application-7 = [ "disabled" ];
      switch-to-application-8 = [ "disabled" ];
      switch-to-application-9 = [ "disabled" ];
      # Désactiver Super+Ctrl+1-9 (ouvrir nouvelle fenêtre app favorite)
      open-new-window-application-1 = [ "disabled" ];
      open-new-window-application-2 = [ "disabled" ];
      open-new-window-application-3 = [ "disabled" ];
      open-new-window-application-4 = [ "disabled" ];
      open-new-window-application-5 = [ "disabled" ];
      open-new-window-application-6 = [ "disabled" ];
      open-new-window-application-7 = [ "disabled" ];
      open-new-window-application-8 = [ "disabled" ];
      open-new-window-application-9 = [ "disabled" ];
      # Désactiver Super+n (focus notification) pour libérer le raccourci
      focus-active-notification = [ "disabled" ];
    };

    # Configuration des workspaces
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 8;
      focus-new-windows = "smart";
    };

    # Désactiver les raccourcis GNOME natifs qui conflictent avec Forge
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "disabled" ];
      toggle-tiled-right = [ "disabled" ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ "disabled" ];
      switch-input-source-backward = [ "disabled" ];
      switch-to-workspace-left = [ "disabled" ];
      switch-to-workspace-right = [ "disabled" ];
      maximize = [ "disabled" ];
      unmaximize = [ "disabled" ];
      # Navigation entre workspaces avec Super+1-7 (AZERTY: &é"'(-è)
      switch-to-workspace-1 = [
        "<Super>1"
        "<Super>ampersand"
      ];
      switch-to-workspace-2 = [
        "<Super>2"
        "<Super>eacute"
      ];
      switch-to-workspace-3 = [
        "<Super>3"
        "<Super>quotedbl"
      ];
      switch-to-workspace-4 = [
        "<Super>4"
        "<Super>apostrophe"
      ];
      switch-to-workspace-5 = [
        "<Super>5"
        "<Super>parenleft"
      ];
      switch-to-workspace-6 = [
        "<Super>6"
        "<Super>minus"
      ];
      switch-to-workspace-7 = [
        "<Super>7"
        "<Super>egrave"
      ];
      switch-to-workspace-8 = [
        "<Super>8"
        "<Super>underscore"
      ];
      # Déplacer fenêtre vers workspace avec Super+Ctrl+1-8 (AZERTY)
      move-to-workspace-1 = [
        "<Super><Ctrl>1"
        "<Super><Ctrl>ampersand"
      ];
      move-to-workspace-2 = [
        "<Super><Ctrl>2"
        "<Super><Ctrl>eacute"
      ];
      move-to-workspace-3 = [
        "<Super><Ctrl>3"
        "<Super><Ctrl>quotedbl"
      ];
      move-to-workspace-4 = [
        "<Super><Ctrl>4"
        "<Super><Ctrl>apostrophe"
      ];
      move-to-workspace-5 = [
        "<Super><Ctrl>5"
        "<Super><Ctrl>parenleft"
      ];
      move-to-workspace-6 = [
        "<Super><Ctrl>6"
        "<Super><Ctrl>minus"
      ];
      move-to-workspace-7 = [
        "<Super><Ctrl>7"
        "<Super><Ctrl>egrave"
      ];
      move-to-workspace-8 = [
        "<Super><Ctrl>8"
        "<Super><Ctrl>underscore"
      ];
    };

    # # Forge - paramètres généraux
    # "org/gnome/shell/extensions/forge" = {
    #   tiling-mode-enabled = true;
    #   stacked-tiling-mode-enabled = true;
    #   tabbed-tiling-mode-enabled = true;
    #   focus-border-toggle = true;
    #   focus-border-size = 3;
    #   window-gap-size = 4;
    #   window-gap-hidden-on-single = false;
    #   float-always-on-top-enabled = true;
    #   move-pointer-focus-enabled = false;
    #   preview-hint-enabled = true;
    # };

    # # Forge - raccourcis clavier
    # "org/gnome/shell/extensions/forge/keybindings" = {
    #   # Focus (Super + flèches)
    #   window-focus-left = [ "<Super>Left" ];
    #   window-focus-right = [ "<Super>Right" ];
    #   window-focus-up = [ "<Super>Up" ];
    #   window-focus-down = [ "<Super>Down" ];

    #   # Déplacer une fenêtre (Shift + Super + flèches)
    #   window-move-left = [ "<Shift><Super>Left" ];
    #   window-move-down = [ "<Shift><Super>Down" ];
    #   window-move-up = [ "<Shift><Super>Up" ];
    #   window-move-right = [ "<Shift><Super>Right" ];

    #   # Swap (Ctrl + Super + flèches)
    #   window-swap-left = [ "<Ctrl><Super>Left" ];
    #   window-swap-down = [ "<Ctrl><Super>Down" ];
    #   window-swap-up = [ "<Ctrl><Super>Up" ];
    #   window-swap-right = [ "<Ctrl><Super>Right" ];

    #   # Layouts
    #   con-split-layout-toggle = [ "<Super>g" ];
    #   con-split-horizontal = [ "<Super>z" ];
    #   con-split-vertical = [ "<Super>v" ];
    #   con-stacked-layout-toggle = [ "<Alt><Super>s" ];
    #   con-tabbed-layout-toggle = [ "<Shift><Super>t" ];
    #   con-tabbed-showtab-decoration-toggle = [ "<Shift><Super>y" ];

    #   # Floating
    #   window-toggle-float = [ "<Super>c" ];
    #   window-toggle-always-float = [ "<Shift><Super>c" ];

    #   # Tiling
    #   prefs-tiling-toggle = [ "<Super>w" ];
    #   workspace-active-tile-toggle = [ "<Shift><Super>w" ];
    #   window-swap-last-active = [ "<Super>Return" ];

    #   # Gaps
    #   window-gap-size-increase = [ "<Alt><Ctrl><Super>plus" ];
    #   window-gap-size-decrease = [ "<Alt><Ctrl><Super>minus" ];

    #   # Resize
    #   # Resize : Ctrl+Shift+Super + flèches (agrandir dans la direction)
    #   window-resize-left-increase = [ "<Ctrl><Shift><Super>Left" ];
    #   window-resize-right-increase = [ "<Ctrl><Shift><Super>Right" ];
    #   window-resize-top-increase = [ "<Ctrl><Shift><Super>Up" ];
    #   window-resize-bottom-increase = [ "<Ctrl><Shift><Super>Down" ];
    #   window-resize-left-decrease = [ "disabled" ];
    #   window-resize-right-decrease = [ "disabled" ];
    #   window-resize-top-decrease = [ "disabled" ];
    #   window-resize-bottom-decrease = [ "disabled" ];

    #   # Snap
    #   window-snap-one-third-left = [ "<Ctrl><Alt>d" ];
    #   window-snap-two-third-left = [ "<Ctrl><Alt>e" ];
    #   window-snap-one-third-right = [ "<Ctrl><Alt>g" ];
    #   window-snap-two-third-right = [ "<Ctrl><Alt>t" ];
    #   window-snap-center = [ "<Ctrl><Alt>c" ];

    #   # Misc
    #   focus-border-toggle = [ "<Super>x" ];
    #   prefs-open = [ "<Super>period" ];
    # };
  };

  # Autostart applications

  xdg.configFile."autostart/kDrive.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=kDrive
    Exec=bash -c "sleep 5 && ${pkgs.appimage-run}/bin/appimage-run /home/loicngr/Apps/kDrive.AppImage"
    StartupNotify=false
    Terminal=false
  '';

  xdg.configFile."autostart/element-desktop.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=Element Desktop
    Exec=bash -c "sleep 5 && element-desktop"
    StartupNotify=false
    Terminal=false
  '';

  xdg.configFile."autostart/keepassxc.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=KeePassXC
    Exec=bash -c "sleep 5 && keepassxc"
    StartupNotify=false
    Terminal=false
  '';

  xdg.configFile."autostart/thunderbird.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=Thunderbird
    Exec=bash -c "sleep 5 && thunderbird --minimized"
    StartupNotify=false
    Terminal=false
  '';

  xdg.configFile."lazygit/commit-prompt.md".source = ../config/lazygit/commit-prompt.md;
  xdg.configFile."lazyworktree/config.yaml".source = ../config/lazyworktree/config.yaml;

  xdg.configFile."micro/colorschemes/dracula.micro".text = ''
    color-link default "#F8F8F2,#282A36"
    color-link comment "#6272A4"
    color-link identifier "#50FA7B"
    color-link identifier.class "#8BE9FD"
    color-link identifier.var "#F8F8F2"
    color-link constant "#BD93F9"
    color-link constant.number "#F8F8F2"
    color-link constant.string "#F1FA8C"
    color-link symbol "#FF79C6"
    color-link symbol.brackets "#F8F8F2"
    color-link symbol.tag "#AE81FF"
    color-link type "italic #8BE9FD"
    color-link type.keyword "#FF79C6"
    color-link special "#FF79C6"
    color-link statement "#FF79C6"
    color-link preproc "#FF79C6"
    color-link underlined "#FF79C6"
    color-link error "bold #FF5555"
    color-link todo "bold #FF79C6"
    color-link diff-added "#50FA7B"
    color-link diff-modified "#FFB86C"
    color-link diff-deleted "#FF5555"
    color-link gutter-error "#FF5555"
    color-link gutter-warning "#E6DB74"
    color-link statusline "#282A36,#F8F8F2"
    color-link tabbar "#282A36,#F8F8F2"
    color-link indent-char "#6272A4"
    color-link line-number "#6272A4"
    color-link current-line-number "#F8F8F2"
    color-link cursor-line "#44475A,#F8F8F2"
    color-link color-column "#44475A"
    color-link type.extended "default"
  '';

  xdg.configFile."micro/settings.json".text = builtins.toJSON {
    colorscheme = "dracula";
  };

}
