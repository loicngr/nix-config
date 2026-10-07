{ config, pkgs, unstable, noctalia, ... }:

{
  xdg.configFile."niri/config.kdl".text = ''
    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "noctalia"

    spawn-at-startup "solaar" "--window=hide"

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

    debug {
        honor-xdg-activation-with-invalid-serial
    }

    window-rule {
        geometry-corner-radius 20
        clip-to-geometry true
        open-focused true
    }

    window-rule {
        match app-id="dev.noctalia.Noctalia"
        open-floating true
        default-column-width { fixed 1080; }
        default-window-height { fixed 920; }
    }

    layer-rule {
        match namespace="^noctalia-wallpaper*"
        place-within-backdrop true
    }

    overview {
        workspace-shadow {
            off
        }
    }

    binds {
        Mod+Return { spawn "kitty" "-e" "tmux" "new-session"; }
        Mod+Shift+Return { spawn "kitty"; }

        Mod+D { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
        Mod+V { spawn "noctalia" "msg" "panel-toggle" "clipboard"; }
        Mod+period { spawn "noctalia" "msg" "panel-toggle" "launcher" "/emo"; }
        Mod+M { spawn "noctalia" "msg" "panel-toggle" "control-center" "monitor"; }

        Mod+Tab { toggle-overview; }

        Mod+Q { close-window; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down { focus-window-down; }

        Mod+Shift+Left { focus-monitor-left; }
        Mod+Shift+Right { focus-monitor-right; }
        Mod+Shift+Up { focus-monitor-up; }
        Mod+Shift+Down { focus-monitor-down; }

        Mod+Alt+Left { move-column-left; }
        Mod+Alt+Right { move-column-right; }
        Mod+Alt+Up { move-window-up; }
        Mod+Alt+Down { move-window-down; }

        Mod+Page_Up { focus-workspace-up; }
        Mod+Page_Down { focus-workspace-down; }

        Mod+WheelScrollUp { focus-workspace-up; }
        Mod+WheelScrollDown { focus-workspace-down; }
        Mod+Alt+WheelScrollUp { focus-column-left; }
        Mod+Alt+WheelScrollDown { focus-column-right; }
        Mod+Shift+WheelScrollUp { focus-column-left; }
        Mod+Shift+WheelScrollDown { focus-column-right; }
        Mod+Shift+Page_Up { move-column-to-workspace-up; }
        Mod+Shift+Page_Down { move-column-to-workspace-down; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+ampersand { focus-workspace 1; }
        Mod+eacute { focus-workspace 2; }
        Mod+quotedbl { focus-workspace 3; }
        Mod+apostrophe { focus-workspace 4; }
        Mod+parenleft { focus-workspace 5; }
        Mod+minus { focus-workspace 6; }
        Mod+egrave { focus-workspace 7; }
        Mod+underscore { focus-workspace 8; }
        Mod+ccedilla { focus-workspace 9; }

        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        Mod+Shift+ampersand { move-column-to-workspace 1; }
        Mod+Shift+eacute { move-column-to-workspace 2; }
        Mod+Shift+quotedbl { move-column-to-workspace 3; }
        Mod+Shift+apostrophe { move-column-to-workspace 4; }
        Mod+Shift+parenleft { move-column-to-workspace 5; }
        Mod+Shift+minus { move-column-to-workspace 6; }
        Mod+Shift+egrave { move-column-to-workspace 7; }
        Mod+Shift+underscore { move-column-to-workspace 8; }
        Mod+Shift+ccedilla { move-column-to-workspace 9; }

        Mod+Ctrl+Left { set-column-width "-10%"; }
        Mod+Ctrl+Right { set-column-width "+10%"; }

        Mod+BracketLeft { consume-window-into-column; }
        Mod+BracketRight { expel-window-from-column; }

        Mod+Space { toggle-window-floating; }

        Print { spawn "noctalia" "msg" "screenshot-region"; }
        Mod+Shift+S { spawn "noctalia" "msg" "screenshot-region"; }
        Mod+Print { spawn "noctalia" "msg" "screenshot-fullscreen"; }

        Mod+Shift+E { quit; }

        XF86AudioRaiseVolume { spawn "noctalia" "msg" "volume-up"; }
        XF86AudioLowerVolume { spawn "noctalia" "msg" "volume-down"; }
        XF86AudioMute { spawn "noctalia" "msg" "volume-mute"; }
        XF86MonBrightnessUp { spawn "noctalia" "msg" "brightness-up"; }
        XF86MonBrightnessDown { spawn "noctalia" "msg" "brightness-down"; }

        XF86AudioPlay { spawn "playerctl" "play-pause"; }
        XF86AudioNext { spawn "playerctl" "next"; }
        XF86AudioPrev { spawn "playerctl" "previous"; }

        Mod+L { spawn "noctalia" "msg" "session" "lock"; }

        Mod+B { spawn "google-chrome-stable"; }
        Mod+Shift+B { spawn "chrome-webgpu"; }
    }
  '';

  programs.noctalia = {
    enable = true;

    settings = {
      accessibility.ui_scale = 0.9;

      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Dracula";

        templates = {
          enable_builtin_templates = false;
          enable_community_templates = false;
          builtin_ids = [ ];
          community_ids = [ ];
        };
      };

      audio = {
        enable_sounds = true;
        notification_sound = "${config.xdg.configHome}/noctalia/notification.mp3";
      };

      shell = {
        avatar_path = "${config.xdg.configHome}/noctalia/logo.jpg";
        setup_wizard_enabled = false;
        clipboard_keep_from_closed_apps = false;
        clipboard_auto_paste = "off";

        session.actions = [
          { action = "lock"; enabled = true; }
          { action = "suspend"; enabled = true; }
          { action = "reboot"; enabled = true; }
          { action = "logout"; enabled = true; }
          { action = "shutdown"; enabled = true; }
        ];

        clipboard_history_max_entries = 200;
        screen_time_enabled = true;

        launcher = {
          compact = true;
          show_app_actions = true;
        };
        screenshot = {
          annotate = true;
          remember_last_region = false;
        };
      };

      notification = {
        background_opacity = 0.9;
        scale = 1.0;
      };

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

      nightlight = {
        enabled = true;
        force = true;
        temperature_day = 6500;
        temperature_night = 4000;
      };

      location = {
        address = "Nîmes";
        custom_schedule = true;
        sunrise = "06:30";
        sunset = "18:30";
      };

      plugins.enabled = [
        "dotnetrob/cat"
        "cleboost/jetbrains-provider"
        "noctalia/notes"
      ];

      widget = {
        cat.type = "dotnetrob/cat:cat";
        media.enabled = false;
        clock.format = "{:%d-%m-%Y %H:%M:%S}";
        brightness.enabled = false;
        notes.type = "noctalia/notes:notes";
      };

      control_center.calendar.show_events_card = true;

      battery.device."/org/freedesktop/UPower/devices/keyboard_dev_DC_FE_19_2B_92_70".warning_threshold = 10;
      battery.device."/org/freedesktop/UPower/devices/mouse_dev_D7_6A_A4_6D_9E_78".warning_threshold = 10;

      dock = {
        enabled = true;
        icon_size = 38;
        main_axis_padding = 12;
        reserve_space = false;
        show_dots = true;
        smart_auto_hide = true;
      };

      calendar = {
        enabled = true;
        account.pro_gmail_loicngr = {
          type = "google";
          name = "pro.nogierloic@gmail.com";
          color = "primary";
        };
      };

      lockscreen.blurred_desktop = true;

      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;
        widget_order = [
          "lockscreen-login-box@DP-2"
          "lockscreen-login-box@HDMI-A-1"
          "lockscreen-login-box@eDP-1"
        ];

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        widget."lockscreen-login-box@DP-2" = {
          type = "login_box";
          output = "DP-2";
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

        widget."lockscreen-login-box@HDMI-A-1" = {
          type = "login_box";
          output = "HDMI-A-1";
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
        margin_ends = 4;
        margin_edge = 4;
        thickness = 30;
        start = [
          "launcher"
          "clock"
          "group:g1"
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
          "notes" # ajouté via l'UI 2026-09-14 (screenshot retiré le même jour)
          "caffeine" # ajouté via l'UI 2026-08-24
          "control-center"
        ];

        capsule_group = [
          {
            id = "g1";
            enabled = true;
            fill = "surface_variant";
            opacity = 1.0;
            padding = 6.0;
            accordion = false;
            accordion_direction = "end";
            members = [ "sysmon" "mini-docker" ];
          }
        ];
      };

      idle = {
        pre_action_fade_seconds = 8.0;

        behavior.screen-off = {
          action = "screen_off";
          timeout = 600;
          enabled = true;
        };

        behavior.lock = {
          action = "lock";
          timeout = 660;
          enabled = true;
        };
      };
    };
  };

  xdg.configFile."noctalia/logo.jpg".source = ../images/logo.jpg;
  xdg.configFile."noctalia/notification.mp3".source = ../sounds/notification.mp3;

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
