{
  config,
  pkgs,
  unstable,
  myPhp82,
  myPhp83,
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
      wayland = true;
    };

    defaultSession = "niri";
  };

  services.gvfs.enable = true;

  # Bluetooth - reconnexion automatique
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        AutoEnable = true;
        FastConnectable = true;
        ReconnectAttempts = 7;
        ReconnectIntervals = "1,2,4,8,16,32,64";
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # Logitech - solaar + règles udev
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # Prérequis Noctalia
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.gnome.evolution-data-server.enable = true;

  # Ne jamais entrer en veille/sommeil profond automatiquement
  services.logind = {
    settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      IdleAction = "ignore";
    };
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

  services.desktopManager.gnome.enable = true;

  programs.niri.enable = true;

  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  };

  # Flatpak
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # Configure console keymap
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
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
      "adbusers"
      "gamemode"
    ];
    packages = with pkgs; [
      thunderbird
    ];
  };

  programs.dconf = {
    enable = true;

    profiles = {
      gdm = {
        databases = [
          {
            settings = {
              "org/gnome/login-screen" = {
                logo = "/etc/gdm/logo.jpg";
                banner-message-enable = true;
                banner-message-text = "Salutation tocard !";
              };
            };
          }
        ];
      };
    };
  };

  environment.etc = {
    "gdm/logo.jpg".source = logoImage;
  };

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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

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
  security.pam.services.swaylock = {};

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
    unstable.lazydocker
    unstable.yazi
    unstable.lazysql
    unstable.lazyjournal
    unstable.lazyworktree
    pkgs.micro
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
    pkgs.fx
    pkgs.nap

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

    # Développement - PHP
    myPhp83
    myPhp83.packages.composer
    myPhp83.packages.php-cs-fixer
    myPhp82
    myPhp82.packages.composer
    myPhp82.packages.php-cs-fixer
    # (pkgs.phpstan.override { php = myPhp83; }) (use local version)
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

    # Wayland / Niri
    pkgs.xwayland-satellite

    # Applications
    pkgs.bitwarden-desktop
    pkgs.appimage-run
  ];

  environment.sessionVariables = {
    PHP_INI_SCAN_DIR = "${myPhp83}/lib";
    BROWSER = "google-chrome-stable";
    EDITOR = "micro";
    VISUAL = "micro";
    TERMINAL = "kitty";
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

  programs.adb.enable = true;

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
    package = pkgs.mariadb;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
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
  # networking.firewall.enable = false;

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
