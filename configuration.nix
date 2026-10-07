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

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.cleanOnBoot = true;

  zramSwap.enable = true;

  services.journald.extraConfig = "SystemMaxUse=500M";

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches"   = 1048576;
    "fs.inotify.max_user_instances" =    1024;
    "fs.inotify.max_queued_events"  =   32768;
    "vm.swappiness"                 =      10;
  };

  networking.hostName = "loicngr";

  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:docker*" "interface-name:br-*" "interface-name:veth*" ];

  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
  ];

  time.timeZone = "Europe/Paris";

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

  services.xserver.enable = true;

  services.displayManager = {
    gdm = {
      enable = true;
    };

    defaultSession = "niri";
  };

  services.gvfs.enable = true;

  services.fstrim.enable = true;

  services.thermald.enable = true;

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

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

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

  services.earlyoom = {
    enable = true;
    freeSwapThreshold = 5;
    freeMemThreshold = 5;
  };

  services.desktopManager.gnome.enable = true;

  programs.niri.enable = true;

  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  console.keyMap = "fr";

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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

  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;
  };
  

  documentation.man.cache.enable = false;

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
    clean.enable = false;
    flake = "/etc/nixos/";
  };

  fonts = {
    enableDefaultPackages = true;

    fontDir = {
      enable = true;
    };

    fontconfig = { };

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
      gnome-text-editor
      hitori
      iagno
      tali
    ]
  );

  environment.systemPackages = [
    pkgs.vim
    pkgs.vscodium
    pkgs.micro

    pkgs.google-chrome

    pkgs.parsec-bin

    pkgs.vlc
    pkgs.ffmpeg
    pkgs.gimp

    pkgs.insomnia
    pkgs.k6

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

    pkgs.fnm
    pkgs.node-gyp
    pkgs.prettierd
    pkgs.eslint
    pkgs.eslint_d
    pkgs.typescript
    pkgs.lua5_1
    pkgs.lua51Packages.luacheck

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

    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt
    pkgs.clippy
    pkgs.rust-analyzer

    pkgs.python314

    pkgs.javaPackages.compiler.openjdk17
    pkgs.javaPackages.compiler.openjdk21

    pkgs.mariadb
    pkgs.postgresql_18
    pkgs.rabbitmq-c

    pkgs.dotool
    pkgs.ydotool
    pkgs.wl-clipboard
    pkgs.cliphist

    pkgs.xwayland-satellite
    pkgs.playerctl
    pkgs.wdisplays

    pkgs.appimage-run

    pkgs.android-tools
  ];

  environment.sessionVariables = {
    PHP_INI_SCAN_DIR = "${myPhp83}/lib";
    BROWSER = "google-chrome-stable";
    EDITOR = "micro";
    VISUAL = "micro";
    TERMINAL = "kitty";

    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  xdg.mime.defaultApplications = {
    "text/html" = "google-chrome.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
    "x-scheme-handler/about" = "google-chrome.desktop";
    "x-scheme-handler/unknown" = "google-chrome.desktop";

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

    "application/pdf" = "google-chrome.desktop";

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
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxshmfence
    libxscrnsaver
    libxtst
    libxi
    libxcursor
    libxrender
    stdenv.cc.cc.lib
    zlib
    SDL
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    SDL_image
    SDL_mixer
    SDL_ttf
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
    atk
    freetype
    freeglut
    fontconfig
    glew_1_10
    gtk2
    harfbuzz
    libGLU
    libcaca
    librsvg
    libvdpau
    pixman
    vulkan-loader
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
    libice
    libsm
    libxft
    libxinerama
    libxmu
    libxt
    libxxf86vm
    libpciaccess
    libxcb-util
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    xkeyboard-config
  ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb_114;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
  };

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
        "https://noctalia.cachix.org"
      ];

      trusted-public-keys = [
        "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
        "codex-cli.cachix.org-1:BH31Jb2xSzV+9BFgVfR9j7TDW3L8CSMziFdfLrKEKIk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };

  system.autoUpgrade.enable = false;

  system.stateVersion = "25.11";
}
