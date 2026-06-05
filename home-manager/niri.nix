{ config, pkgs, unstable, noctalia, ... }:

{
  # ==========================================================================
  # Niri - Configuration du compositeur Wayland
  # ==========================================================================

  xdg.configFile."niri/config.kdl".text = ''
    // Programmes lancés au démarrage
    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "noctalia-shell"

    spawn-at-startup "solaar" "--window=hide"

    // Désactivé: forcer DISPLAY sous Wayland peut casser des apps Xwayland.
    // environment {
    //     DISPLAY ":0"
    // }

    input {
        keyboard {
            xkb {
                layout "fr"
            }
            numlock
        }
        touchpad {
            tap
            natural-scroll
        }
        focus-follows-mouse max-scroll-amount="0%"
    }

    layout {
        // Stationary wallpaper: rendre les workspaces transparents pour voir le backdrop en permanence.
        background-color "transparent"

        gaps 8

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width {
            proportion 1.0
        }

        focus-ring {
            width 2
            active-color "#cba6f7"
            inactive-color "#585b70"
        }

        border {
            off
        }
    }

    cursor {
        xcursor-theme "catppuccin-mocha-mauve-cursors"
        xcursor-size 24
    }

    hotkey-overlay {
        skip-at-startup
    }

    prefer-no-csd

    screenshot-path "~/Images/Screenshots/%Y-%m-%d_%H-%M-%S.png"

    // Noctalia - config spécifique
    debug {
        honor-xdg-activation-with-invalid-serial
    }

    window-rule {
        geometry-corner-radius 20
        clip-to-geometry true
        open-focused true
    }

    layer-rule {
        // Stationary wallpaper: placer le layer wallpaper sur le backdrop.
        match namespace="^noctalia-wallpaper*"
        place-within-backdrop true
    }

    // Optionnel: retirer l'ombre des workspaces dans l'overview.
    overview {
        workspace-shadow {
            off
        }
    }

    binds {
        // Terminal
        Mod+Return { spawn "kitty" "-e" "tmux" "new-session"; }
        Mod+Shift+Return { spawn "kitty"; }

        // Lanceur Noctalia
        Mod+D { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
        Mod+V { spawn "noctalia-shell" "ipc" "call" "launcher" "toggleClipboard"; }
        Mod+period { spawn "noctalia-shell" "ipc" "call" "launcher" "toggleEmoji"; }
        Mod+M { spawn "noctalia-shell" "ipc" "call" "systemMonitor" "toggle"; }

        // Overview (vue de tous les workspaces)
        Mod+Tab { toggle-overview; }

        // Gestion des fenêtres
        Mod+Q { close-window; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        // Focus
        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down { focus-window-down; }

        // Déplacer entre les moniteurs
        Mod+Shift+Left { focus-monitor-left; }
        Mod+Shift+Right { focus-monitor-right; }
        Mod+Shift+Up { focus-monitor-up; }
        Mod+Shift+Down { focus-monitor-down; }

        // Déplacer les fenêtres
        Mod+Alt+Left { move-column-left; }
        Mod+Alt+Right { move-column-right; }
        Mod+Alt+Up { move-window-up; }
        Mod+Alt+Down { move-window-down; }

        // Workspaces - navigation séquentielle
        Mod+Page_Up { focus-workspace-up; }
        Mod+Page_Down { focus-workspace-down; }

        // Navigation molette souris
        Mod+WheelScrollUp { focus-workspace-up; }
        Mod+WheelScrollDown { focus-workspace-down; }
        Mod+Alt+WheelScrollUp { focus-column-left; }
        Mod+Alt+WheelScrollDown { focus-column-right; }
        Mod+Shift+WheelScrollUp { focus-column-left; }
        Mod+Shift+WheelScrollDown { focus-column-right; }
        Mod+Shift+Page_Up { move-column-to-workspace-up; }
        Mod+Shift+Page_Down { move-column-to-workspace-down; }

        // Workspaces - focus (chiffres)
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        // Workspaces - focus (AZERTY sans Shift : & é " ' ( - è _ ç)
        Mod+ampersand { focus-workspace 1; }
        Mod+eacute { focus-workspace 2; }
        Mod+quotedbl { focus-workspace 3; }
        Mod+apostrophe { focus-workspace 4; }
        Mod+parenleft { focus-workspace 5; }
        Mod+minus { focus-workspace 6; }
        Mod+egrave { focus-workspace 7; }
        Mod+underscore { focus-workspace 8; }
        Mod+ccedilla { focus-workspace 9; }

        // Workspaces - déplacer fenêtre (chiffres)
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        // Workspaces - déplacer fenêtre (AZERTY)
        Mod+Shift+ampersand { move-column-to-workspace 1; }
        Mod+Shift+eacute { move-column-to-workspace 2; }
        Mod+Shift+quotedbl { move-column-to-workspace 3; }
        Mod+Shift+apostrophe { move-column-to-workspace 4; }
        Mod+Shift+parenleft { move-column-to-workspace 5; }
        Mod+Shift+minus { move-column-to-workspace 6; }
        Mod+Shift+egrave { move-column-to-workspace 7; }
        Mod+Shift+underscore { move-column-to-workspace 8; }
        Mod+Shift+ccedilla { move-column-to-workspace 9; }

        // Redimensionner les colonnes
        Mod+Ctrl+Left { set-column-width "-10%"; }
        Mod+Ctrl+Right { set-column-width "+10%"; }

        // Colonnes - absorber / expulser
        Mod+BracketLeft { consume-window-into-column; }
        Mod+BracketRight { expel-window-from-column; }

        // Floating
        Mod+Space { toggle-window-floating; }

        // Screenshots
        Print { screenshot; }
        Mod+Shift+S { screenshot; }
        Mod+Print { screenshot-window; }

        // Session
        Mod+Shift+E { quit; }

        // Audio / Luminosité (Noctalia IPC)
        XF86AudioRaiseVolume { spawn "noctalia-shell" "ipc" "call" "volume" "increase"; }
        XF86AudioLowerVolume { spawn "noctalia-shell" "ipc" "call" "volume" "decrease"; }
        XF86AudioMute { spawn "noctalia-shell" "ipc" "call" "volume" "muteOutput"; }
        XF86MonBrightnessUp { spawn "noctalia-shell" "ipc" "call" "brightness" "increase"; }
        XF86MonBrightnessDown { spawn "noctalia-shell" "ipc" "call" "brightness" "decrease"; }

        // Media
        XF86AudioPlay { spawn "playerctl" "play-pause"; }
        XF86AudioNext { spawn "playerctl" "next"; }
        XF86AudioPrev { spawn "playerctl" "previous"; }

        // Session
        Mod+L { spawn "noctalia-shell" "ipc" "call" "lockScreen" "lock"; }

        // Applications
        Mod+B { spawn "google-chrome-stable"; }
    }
  '';

  # ==========================================================================
  # Noctalia - Shell desktop Wayland
  # ==========================================================================

  programs.noctalia-shell = {
    enable = true;
    package = noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      calendarSupport = true;
    };
    settings = ../config/noctalia/settings.json;
    colors = ../config/noctalia/colors.json;
    plugins = ../config/noctalia/plugins.json;
  };

  xdg.configFile."noctalia/logo.jpg".source = ../images/logo.jpg;


  # ==========================================================================
  # Thème GTK + Curseur (Catppuccin Mocha)
  # ==========================================================================

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-mauve-standard+default";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "catppuccin-mocha-mauve-cursors";
      package = pkgs.catppuccin-cursors.mochaMauve;
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    # 26.05 : le défaut de gtk4.theme est passé à null. On conserve l'apparence
    # actuelle (apps GTK4 thémées Catppuccin) en réutilisant le thème GTK global.
    gtk4.theme = config.gtk.theme;
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  home.pointerCursor = {
    name = "catppuccin-mocha-mauve-cursors";
    package = pkgs.catppuccin-cursors.mochaMauve;
    size = 24;
    gtk.enable = true;
  };
}
