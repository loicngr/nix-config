{ config, pkgs, unstable, noctalia, ... }:

{
  # ==========================================================================
  # Niri - Configuration du compositeur Wayland
  # ==========================================================================

  xdg.configFile."niri/config.kdl".text = ''
    // Programmes lancés au démarrage
    spawn-at-startup "xwayland-satellite"
    // Démarrage recommandé par la doc v5 (« running-the-shell ») : autostart
    // compositeur. On n'active PAS programs.noctalia.systemd.enable -> un seul
    // mécanisme de démarrage, jamais les deux (double instance).
    spawn-at-startup "noctalia"

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

    // Fenêtre de réglages Noctalia v5 : flottante et dimensionnée (reco doc v5).
    window-rule {
        match app-id="dev.noctalia.Noctalia"
        open-floating true
        default-column-width { fixed 1080; }
        default-window-height { fixed 920; }
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
        Mod+D { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
        Mod+V { spawn "noctalia" "msg" "panel-toggle" "clipboard"; }
        // v5: l'emoji picker est un provider du launcher, pas un panel.
        // `launcher /emo` est l'exemple donné littéralement par l'aide upstream.
        Mod+period { spawn "noctalia" "msg" "panel-toggle" "launcher" "/emo"; }
        // v5: pas de panel system-monitor (sysmon n'est qu'un widget de barre)
        // -> onglet `monitor` du control-center (= geste par défaut du widget sysmon).
        Mod+M { spawn "noctalia" "msg" "panel-toggle" "control-center" "monitor"; }

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
        XF86AudioRaiseVolume { spawn "noctalia" "msg" "volume-up"; }
        XF86AudioLowerVolume { spawn "noctalia" "msg" "volume-down"; }
        XF86AudioMute { spawn "noctalia" "msg" "volume-mute"; }
        XF86MonBrightnessUp { spawn "noctalia" "msg" "brightness-up"; }
        XF86MonBrightnessDown { spawn "noctalia" "msg" "brightness-down"; }

        // Media
        XF86AudioPlay { spawn "playerctl" "play-pause"; }
        XF86AudioNext { spawn "playerctl" "next"; }
        XF86AudioPrev { spawn "playerctl" "previous"; }

        // Session
        Mod+L { spawn "noctalia" "msg" "session" "lock"; }

        // Applications
        Mod+B { spawn "google-chrome-stable"; }
        Mod+Shift+B { spawn "chrome-webgpu"; }
    }
  '';

  # ==========================================================================
  # Noctalia - Shell desktop Wayland
  # ==========================================================================

  programs.noctalia = {
    enable = true;

    # `package` est posé en mkDefault par homeModules.default (= packages.<sys>.default)
    # -> ne pas le redéclarer. `.override { calendarSupport = ...; }` n'existe plus en v5.

    # Minimal déclaratif : thème + barre + les réglages de COMPORTEMENT et de
    # SÉCURITÉ dont le défaut v5 régresserait (idle, wizard, clipboard, session,
    # osd, nightlight, templates). Le cosmétique garde les défauts v5 et se règle
    # via l'UI (couche ~/.local/state/noctalia/settings.toml, prioritaire + hot
    # reload), puis `noctalia config export` -> re-fold ici (Task 9).
    # Référence des réglages v4 : config/noctalia/v4-archive/settings.json
    settings = {
      # Thème builtin : les couleurs custom v4 ne sont pas migrées (décision).
      # v4 utilisait déjà colorSchemes.predefinedScheme = "Noctalia (default)".
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Dracula"; # re-tuning UI 2026-08-06 (était "Noctalia")

        # Templates DÉSACTIVÉS. Défauts v5: enable_builtin_templates = true et
        # enable_community_templates = true (config_types.h:1429-1430). Les templates
        # livrés ciblent kitty / niri / gtk / qt / helix / starship... or ici
        # ~/.config/kitty, ~/.config/niri/config.kdl et le thème GTK sont des SYMLINKS
        # Home Manager en lecture seule -> écriture en échec, ou fichier réel qui fera
        # planter les activations HM suivantes ("would be clobbered").
        templates = {
          enable_builtin_templates = false;
          enable_community_templates = false;
          builtin_ids = [ ];
          community_ids = [ ];
        };
      };

      shell = {
        # v4: general.avatarImage. Garde l'avatar sur le logo versionné du dépôt.
        avatar_path = "${config.xdg.configHome}/noctalia/logo.jpg";

        # OBLIGATOIRE. Défaut v5: setup_wizard_enabled = true (config_types.h:1015),
        # et l'assistant s'ouvre tant que ~/.local/state/noctalia/ n'a pas son marqueur
        # (config_service.cpp:696-703) -- ce répertoire n'existe pas encore ici, donc
        # il s'ouvrirait au premier lancement. Or il PERSISTE ses réponses dans la
        # couche d'état, PRIORITAIRE sur ce fichier -> il masquerait silencieusement
        # tout ce bloc, y compris [idle].
        setup_wizard_enabled = false;

        # Clipboard natif (remplace le plugin clipper).
        # Défaut v5 = true : le shell RÉCLAME la sélection quand l'app qui a copié se
        # ferme. Un gestionnaire de mots de passe qui vide le presse-papier en quittant
        # est indistinguable d'une app ordinaire -> son secret survit. On désactive.
        clipboard_keep_from_closed_apps = false;
        # Défaut v5 = "auto" : choisir une entrée d'historique la COLLE directement
        # dans la fenêtre focalisée. v4 avait autoPasteClipboard = false.
        clipboard_auto_paste = "off";

        # Menu de session : v5 réordonne les actions (config_types.cpp:93-117) ->
        # lock, logout, lock_and_suspend, reboot, shutdown. La touche 2 deviendrait
        # "logout" (v4: suspend) et la 5 "shutdown" (v4: logout) : la mémoire
        # musculaire ferait perdre du travail. On reprend l'ordre v4.
        # NB: déclarer une seule action remplace TOUTE la liste par défaut.
        session.actions = [
          { action = "lock"; enabled = true; }
          { action = "suspend"; enabled = true; }
          { action = "reboot"; enabled = true; }
          { action = "logout"; enabled = true; }
          { action = "shutdown"; enabled = true; }
        ];
      };

      # OSD : v4 n'affichait que 3 types (osd.enabledTypes = [0,1,2]) ; v5 active les
      # 15 (config_types.h:653-670), dont `lock_keys` -- qui implique un POLLING en
      # tâche de fond, et `numlock` est actif dans la config niri. On revient au strict
      # nécessaire (cf. l'épisode de surchauffe du 06/08).
      osd.kinds = {
        volume = true;
        volume_output = true;
        brightness = true;
        volume_input = false;
        wifi = false;
        bluetooth = false;
        power_profile = false;
        caffeine = false;
        nightlight = false;
        dnd = false;
        lock_keys = false;
        keyboard_layout = false;
        media = false;
        privacy = false;
        keyboard_backlight = false;
      };

      # Night light : v4 l'avait `enabled = true` ET `forced = true` ; le défaut v5 est
      # `enabled = false` -> disparition silencieuse d'un confort quotidien.
      # Il dépend de [location] pour le planning jour/nuit : sans adresse, pas de
      # planification automatique -> on reprend les horaires manuels de v4.
      nightlight = {
        enabled = true;
        force = true; # v4: nightLight.forced -- la clé v5 est `force`, sans "d"
        temperature_day = 6500;
        temperature_night = 4000;
      };

      # [location] alimente le planning jour/nuit du night light (et la météo).
      # v4: manualSunrise 06:30 / manualSunset 18:30 -> en v5 c'est `custom_schedule`
      # + sunrise/sunset. On l'utilise plutôt que `address = "Nîmes"` : pas de
      # géocodage réseau, et le résultat est déterministe.
      location = {
        address = "Nîmes"; # utilisé par la météo (v4: location.name)
        # Planning jour/nuit du night light : horaires manuels plutôt que
        # géocodage de l'adresse (v4: manualSunrise/manualSunset).
        custom_schedule = true;
        sunrise = "06:30";
        sunset = "18:30";
      };

      # Plugins v5 (Luau). Sources `official` + `community` = défauts, rien à déclarer.
      plugins.enabled = [ "dotnetrob/cat" ];

      # Réglages par widget (v5 les sort du tableau de la barre).
      widget = {
        cat.type = "dotnetrob/cat:cat";
        media.enabled = false;
        # Format chrono (v4 utilisait le format Qt "HH:mm ddd, MMM dd").
        clock.format = "{:%d-%m-%Y %H:%M:%S}";
      };

      control_center.calendar.show_events_card = false;

      # Widgets de l'écran de verrouillage (positionnés via l'UI, liés à eDP-1).
      # `enabled = false` : la fonctionnalité reste inactive, la disposition est
      # simplement mémorisée.
      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;
        widget_order = [ "lockscreen-login-box@eDP-1" ];

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        widget."lockscreen-login-box@eDP-1" = {
          type = "login_box";
          output = "eDP-1";
          cx = 960.0;
          cy = 898.0;
          box_width = 810.0;
          box_height = 196.0;
          rotation = 0.0;

          settings = {
            background_color = "surface_variant";
            background_opacity = 0.88;
            background_radius = 12.0;
            center_password_text = false;
            input_opacity = 1.0;
            input_radius = 6.0;
            layout = "regular";
            show_caps_lock = true;
            show_keyboard_layout = true;
            show_login_button = true;
            show_media = true;
            show_session_buttons = true;
            show_unlock_hint = true;
            show_weather = true;
          };
        };
      };

      bar.main = {
        position = "top";
        background_opacity = 0.93;
        capsule = true;
        # Défauts v5 : margin_ends = 180 (!) et margin_edge = 10 -> barre encastrée
        # de 180 px à chaque bout. v4 avait marginHorizontal/marginVertical = 4.
        margin_ends = 4;
        margin_edge = 4;
        thickness = 30; # défaut v5 = 34
        # Disposition v4 ; `cat` = plugin communautaire dotnetrob/cat, qui remplace
        # le plugin v4 `catwalk` (chat animé) abandonné faute d'équivalent officiel.
        start = [
          "launcher"
          "clock"
          "sysmon"
          "active_window"
          "media"
          "cat"
        ];
        center = [ "workspaces" ];
        end = [
          "tray"
          "notifications"
          "clipboard"
          "battery"
          "volume"
          "brightness"
          "control-center"
        ];
      };

      # Idle : porté explicitement (exception au minimal). Raison : les 3 comportements
      # built-in de v5 sont `enabled = false` -> sans déclaration, la machine ne se
      # verrouillerait plus jamais automatiquement (v4 faisait 600/660).
      # NB: déclarer au moins un behavior désactive TOUS les built-ins
      # (config_service.cpp:1691) -> inutile de déclarer un suspend à false,
      # son absence ici suffit à garantir qu'aucun suspend n'existe.
      idle = {
        pre_action_fade_seconds = 8.0; # v4: fadeDuration = 8

        behavior.screen-off = {
          action = "screen_off";
          timeout = 600; # v4: screenOffTimeout
          enabled = true;
        };

        behavior.lock = {
          action = "lock";
          timeout = 660; # v4: lockTimeout
          enabled = true;
        };
      };
    };
  };

  # Avatar référencé par settings.shell.avatar_path ci-dessus.
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
