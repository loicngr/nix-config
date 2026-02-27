{ myPhp82, myPhp83, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "npm"
        "node"
        "z"
        "docker"
        "sudo"
        "kubectl"
        "history"
        "helm"
        "fzf"
      ];
      theme = "robbyrussell";
    };

    shellAliases = {
      ll = "eza -l";
      lla = "eza -la";
      la = "eza -a";
      ls = "eza";

      cat = "bat";
      open = "nautilus";

      nu = "nh os switch /etc/nixos && nh home switch /etc/nixos";
      nup = "sudo nix flake update --flake /etc/nixos && nh os switch /etc/nixos && nh home switch /etc/nixos";
      nd = "sudo nix-collect-garbage --delete-older-than 30d && nu";
      ncg = "nh clean all --ask";

      claudo = "claude --dangerously-skip-permissions";

      # Tmux project sessions
      ts = "tmux-project sekur";
      tsa = "tmux-project sekur-africa";
      tp = "tmux-project propret";
      tn = "tmux-project nixos";

      # PHP versions
      php82 = "PHP_INI_SCAN_DIR=${myPhp82}/lib ${myPhp82}/bin/php";
      php83 = "PHP_INI_SCAN_DIR=${myPhp83}/lib ${myPhp83}/bin/php";
      composer82 = "PHP_INI_SCAN_DIR=${myPhp82}/lib ${myPhp82.packages.composer}/bin/composer";
      composer83 = "PHP_INI_SCAN_DIR=${myPhp83}/lib ${myPhp83.packages.composer}/bin/composer";
    };

    interactiveShellInit = ''
      # Initialisation fnm avec auto-switch
      eval "$(fnm env --use-on-cd)"

      # PHP version switching functions
      use-php82() {
        export PHP_INI_SCAN_DIR="${myPhp82}/lib"
        export PATH="${myPhp82}/bin:${myPhp82.packages.composer}/bin:$PATH"
        alias composer="${myPhp82.packages.composer}/bin/composer"
        echo "✓ PHP 8.2 activé (php: ${myPhp82}/bin/php, composer: ${myPhp82.packages.composer}/bin/composer)"
      }

      use-php83() {
        export PHP_INI_SCAN_DIR="${myPhp83}/lib"
        export PATH="${myPhp83}/bin:${myPhp83.packages.composer}/bin:$PATH"
        alias composer="${myPhp83.packages.composer}/bin/composer"
        echo "✓ PHP 8.3 activé (php: ${myPhp83}/bin/php, composer: ${myPhp83.packages.composer}/bin/composer)"
      }

      export_app_name_from_env() {
          local current_dir="$PWD"
          local max_depth=5
          local depth=0

          while [ $depth -lt $max_depth ]; do
              if [ -f "$current_dir/.env" ]; then
                  local app_name=$(grep -E "^APP_NAME=" "$current_dir/.env" | cut -d '=' -f 2- | tr -d '"' | tr -d "'")

                  if [ -n "$app_name" ]; then
                      export APP_NAME="$app_name"
                      echo "✓ APP_NAME exporté: $app_name (depuis $current_dir/.env)"
                      return 0
                  fi
              fi

              if [ "$current_dir" = "/" ]; then
                  break
              fi

              current_dir=$(dirname "$current_dir")
              depth=$((depth + 1))
          done

          return 1
      }

      autoload -Uz add-zsh-hook
      add-zsh-hook chpwd export_app_name_from_env
      export_app_name_from_env

      # Local bin
      export PATH="$HOME/.local/bin:$PATH"

      # Android tools
      export ANDROID_HOME="$HOME/Android/Sdk"
      export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
      export PATH="$PATH:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools"

      export XDG_DATA_HOME="$HOME/.local/share"

      # Bun bin
      export PATH="$HOME/.bun/bin:$PATH"
    '';
  };
}
