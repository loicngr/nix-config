{
  config,
  pkgs,
  unstable,
  myPhp83,
  myPhp84,
  myPhp85,
  ...
}:

let
  backgroundImage = ./images/background.jpg;
  logoImage = ./images/logo.jpg;

in
{
  imports = [
    ./hardware-configuration.nix
    ./modules/php.nix
    ./modules/nvidia.nix
    ./modules/zsh.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Nettoyage de /tmp au boot pour libérer la RAM (tmpfs)
  boot.tmp.cleanOnBoot = true;

  # zramSwap : amortisseur RAM compressé en complément du swapfile disque
  zramSwap.enable = true;

  # Limite la taille des logs systemd pour éviter qu'ils grossissent indéfiniment
  services.journald.extraConfig = "SystemMaxUse=500M";

  # Increase the amount of inotify watchers
  # Note that inotify watches consume 1kB on 64-bit machines.
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches"   = 1048576;   # default:  8192
    "fs.inotify.max_user_instances" =    1024;   # default:   128
    "fs.inotify.max_queued_events"  =   32768;   # default: 16384
    "vm.swappiness"                 =      10;   # default:    60 (préfère vider le page cache que swapper)
  };

  networking.hostName = "loicngr"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.displayManager = {
    gdm = {
      enable = true;
    };

    defaultSession = "niri";
  };

  services.gvfs.enable = true;

  # TRIM hebdomadaire pour SSD (longévité + perf d'écriture)
  services.fstrim.enable = true;

  # Gestion thermique active (Intel) - évite le throttling sous charge soutenue
  services.thermald.enable = true;

  # dbus-broker : implémentation moderne (par systemd), plus rapide que dbus-daemon
  services.dbus.implementation = "broker";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = true;
      };
    };
  };

  # Logitech - solaar + udev
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # Prérequis Noctalia
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.gnome.evolution-data-server.enable = true;

  services.logind = {
    settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      IdleAction = "ignore";
    };
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };

  # Earlyoom — tue les process gourmands avant que le système gèle
  services.earlyoom = {
    enable = true;
    freeSwapThreshold = 5;
    freeMemThreshold = 5;
  };

  # Swapfile supplémentaire (16 GB) en complément de la partition swap
  #swapDevices = [
  #  {
  #    device = "/swapfile";
  #    size = 16384; # 16 GB en MB
  #  }
  #];

  services.desktopManager.gnome.enable = true;

  programs.niri.enable = true;

  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  };

  # xdg.portal : nécessaire pour Wayland (file pickers, screen sharing, etc.)
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  virtualisation.docker.enable = true;

  users.users.loicngr = {
    isNormalUser = true;
    description = "loicngr";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
      "kvm"
      "gamemode"
    ];
    packages = with pkgs; [
      thunderbird
    ];
  };

  programs.dconf = {
    enable = true;
  };

  # GameMode : optimisations CPU/scheduler à la demande (active le groupe `gamemode`)
  programs.gamemode.enable = true;

  # https://wiki.nixos.org/wiki/Steam
  programs.steam = {
    enable = true;
  };
  

  # Désactive la génération du cache mandb à chaque rebuild (gain build time)
  documentation.man.generateCaches = false;

  programs.firefox.enable = true;

  programs.nano = {
    enable = true;
    nanorc = "
      set mouse
      set autoindent
      set linenumbers
    ";
    syntaxHighlight = true;
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 3d";
    };
    flake = "/etc/nixos/";
  };

  fonts = {
    enableDefaultPackages = true;

    fontDir = {
      enable = true;
    };

    fontconfig = {
      # useEmbeddedBitmaps = true;
    };

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-sans
      nerd-fonts.ubuntu-mono
      nerd-fonts.adwaita-mono
    ];
  };

  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  environment.gnome.excludePackages = (
    with pkgs;
    [
      atomix
      geary
      gnome-terminal
      hitori
      iagno
      tali
    ]
  );

  environment.systemPackages = [
    # Éditeurs & IDE
    pkgs.vim
    pkgs.vscodium
    pkgs.micro

    # Navigateurs
    pkgs.google-chrome

    # Streaming/Remote
    pkgs.parsec-bin

    # Video
    pkgs.vlc
    pkgs.ffmpeg

    # API
    pkgs.insomnia

    # Terminal & Shell & Utilitaires système
    pkgs.btop
    pkgs.fd
    pkgs.htop
    pkgs.nvtopPackages.nvidia
    pkgs.rsync
    pkgs.jq
    pkgs.just
    pkgs.ripgrep
    pkgs.yq
    pkgs.nautilus
    pkgs.ncdu
    pkgs.p7zip
    pkgs.zip
    pkgs.tldr
    pkgs.tree
    pkgs.unzip
    pkgs.wget
    pkgs.lshw
    pkgs.home-manager
    pkgs.pulseaudio

    # Développement - Build tools
    pkgs.autoconf
    pkgs.automake
    pkgs.gcc
    pkgs.gnumake
    pkgs.libgcc
    pkgs.libiconv
    pkgs.libtool
    pkgs.makeWrapper
    pkgs.pkg-config
    pkgs.ghostscript

    # Développement - Node.js
    pkgs.fnm
    pkgs.node-gyp
    pkgs.prettierd
    pkgs.eslint
    pkgs.eslint_d
    pkgs.typescript
    pkgs.lua5_1
    pkgs.lua51Packages.luacheck

    # Développement - PHP
    myPhp83
    myPhp83.packages.composer
    myPhp83.packages.php-cs-fixer
    myPhp84
    myPhp84.packages.composer
    myPhp84.packages.php-cs-fixer
    myPhp85
    myPhp85.packages.composer
    myPhp85.packages.php-cs-fixer
    (pkgs.writeShellScriptBin "php84" ''
      unset PHPRC
      export PHP_INI_SCAN_DIR=${myPhp84}/lib
      exec ${myPhp84}/bin/php "$@"
    '')
    (pkgs.writeShellScriptBin "composer84" ''
      unset PHPRC
      export PHP_INI_SCAN_DIR=${myPhp84}/lib
      exec ${myPhp84.packages.composer}/bin/composer "$@"
    '')
    (pkgs.writeShellScriptBin "php85" ''
      unset PHPRC
      export PHP_INI_SCAN_DIR=${myPhp85}/lib
      exec ${myPhp85}/bin/php "$@"
    '')
    (pkgs.writeShellScriptBin "composer85" ''
      unset PHPRC
      export PHP_INI_SCAN_DIR=${myPhp85}/lib
      exec ${myPhp85.packages.composer}/bin/composer "$@"
    '')
    pkgs.symfony-cli

    # Développement - Python
    pkgs.python314

    # Développement - Java
    pkgs.javaPackages.compiler.openjdk17

    # Développement - Bases de données
    pkgs.mariadb
    pkgs.postgresql
    pkgs.rabbitmq-c

    # Fake keyboard/mouse input
    pkgs.dotool
    pkgs.ydotool
    pkgs.wl-clipboard
    pkgs.cliphist

    # Wayland / Niri
    pkgs.xwayland-satellite
    pkgs.playerctl

    # Applications
    # pkgs.bitwarden-desktop
    pkgs.appimage-run

    # Android (adb/fastboot — remplace programs.adb supprimé en 26.05)
    pkgs.android-tools
  ];

  environment.sessionVariables = {
    PHP_INI_SCAN_DIR = "${myPhp83}/lib";
    BROWSER = "google-chrome-stable";
    EDITOR = "micro";
    VISUAL = "micro";
    TERMINAL = "kitty";

    # Wayland natif (réduit XWayland, meilleure scaling HiDPI, moins de latence)
    MOZ_ENABLE_WAYLAND = "1";                  # Firefox
    QT_QPA_PLATFORM = "wayland;xcb";           # Qt avec fallback X11
    SDL_VIDEODRIVER = "wayland";               # SDL/jeux
    _JAVA_AWT_WM_NONREPARENTING = "1";         # JetBrains/Java sous WM tiling
  };

  xdg.mime.defaultApplications = {
    # Navigateur
    "text/html" = "google-chrome.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
    "x-scheme-handler/about" = "google-chrome.desktop";
    "x-scheme-handler/unknown" = "google-chrome.desktop";

    # Éditeur de code
    "text/plain" = "codium.desktop";
    "text/x-python" = "codium.desktop";
    "text/x-java" = "codium.desktop";
    "text/x-php" = "codium.desktop";
    "text/x-shellscript" = "codium.desktop";
    "text/x-c" = "codium.desktop";
    "text/x-c++" = "codium.desktop";
    "text/css" = "codium.desktop";
    "text/javascript" = "codium.desktop";
    "application/json" = "codium.desktop";
    "application/xml" = "codium.desktop";
    "application/x-yaml" = "codium.desktop";
    "application/toml" = "codium.desktop";

    # PDF
    "application/pdf" = "google-chrome.desktop";

    # Images
    "image/png" = "org.gnome.eog.desktop";
    "image/jpeg" = "org.gnome.eog.desktop";
    "image/gif" = "org.gnome.eog.desktop";
    "image/webp" = "org.gnome.eog.desktop";
    "image/svg+xml" = "org.gnome.eog.desktop";
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    fnm
    # Electron / Chromium / Cypress
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libglvnd
    libxkbcommon
    mesa
    libgbm
    nspr
    nss
    pango
    systemd
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg.libxshmfence
    # Cypress spécifique
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libXi
    xorg.libXcursor
    xorg.libXrender
    # Libs communes
    stdenv.cc.cc.lib
    zlib
    # SDL
    SDL
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    SDL_image
    SDL_mixer
    SDL_ttf
    # Audio / Video
    flac
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    libcanberra
    libjack2
    libmikmod
    libogg
    libpulseaudio
    libsamplerate
    libtheora
    libvorbis
    libvpx
    speex
    # Graphics
    atk
    freetype
    freeglut
    fontconfig
    glew110
    gtk2
    harfbuzz
    libGLU
    libcaca
    librsvg
    libvdpau
    pixman
    vulkan-loader
    # Libs système
    bzip2
    curlWithGnuTls
    dbus-glib
    desktop-file-utils
    e2fsprogs
    fribidi
    fuse
    fuse3
    gmp
    icu
    keyutils.lib
    libappindicator-gtk2
    libcap
    libclang.lib
    libdbusmenu
    libgcrypt
    libgpg-error
    libidn
    libjpeg
    libthai
    libtiff
    libudev0-shim
    libusb1
    libuuid
    libpng12
    libxml2
    libxcrypt-legacy
    openssl
    p11-kit
    python3
    tbb
    udev
    wayland
    xz
    # X11 supplémentaires
    xorg.libICE
    xorg.libSM
    xorg.libXft
    xorg.libXinerama
    xorg.libXmu
    xorg.libXt
    xorg.libXxf86vm
    xorg.libpciaccess
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xkeyboardconfig
  ];

  services.mysql = {
    enable = true;
    # Épinglé sur 11.4 (LTS) pour garder le datadir compatible lors du passage à 26.05
    package = pkgs.mariadb_114;
  };

  services.postgresql = {
    enable = true;
    # Épinglé sur PostgreSQL 17 pour éviter un saut de majeure (datadir incompatible) en 26.05
    package = pkgs.postgresql_17;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  networking.firewall.enable = false;

  nix = {
    optimise.automatic = true;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "root"
        "loicngr"
      ];

      substituters = [
        "https://claude-code.cachix.org"
        "https://nix-community.cachix.org"
        # "https://cache.nixos-cuda.org"
      ];

      trusted-public-keys = [
        "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
        "codex-cli.cachix.org-1:BH31Jb2xSzV+9BFgVfR9j7TDW3L8CSMziFdfLrKEKIk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
    };
  };

  # Auto system update
  system.autoUpgrade.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
