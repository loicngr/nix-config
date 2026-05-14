{ pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "catppuccin"
      "nix"
      "vue"
      "twig"
      "dockerfile"
      "docker-compose"
      "ruff"
      "psalm"
    ];

    userTasks = [
      {
        label = "PHPStan: analyse projet";
        command = "phpstan-wrapper";
        args = [ "analyse" ];
        use_new_terminal = false;
        reveal = "always";
      }
      {
        label = "PHPStan: analyse fichier courant";
        command = "phpstan-wrapper";
        args = [ "analyse" "$ZED_FILE" ];
        use_new_terminal = false;
        reveal = "always";
      }
    ];

    userSettings = {
      theme = {
        mode = "dark";
        light = "Catppuccin Latte";
        dark = "Catppuccin Mocha";
      };

      ui_font_size = 16;
      buffer_font_size = 16;
      buffer_font_family = "FiraCode Nerd Font";
      ui_font_family = "Ubuntu Nerd Font";

      vim_mode = false;
      base_keymap = "JetBrains";
      colorize_brackets = true;

      diagnostics = {
        inline = { enabled = true; };
      };

      inlay_hints = {
        enabled = true;
      };

      auto_update = false;
      show_whitespaces = "selection";
      load_direnv = "shell_hook";
      hour_format = "hour24";

      node = {
        path = "${pkgs.nodejs_24}/bin/node";
        npm_path = "${pkgs.nodejs_24}/bin/npm";
      };

      terminal = {
        shell = "system";
        dock = "bottom";
        font_family = "FiraCode Nerd Font";
        line_height = "comfortable";
        copy_on_select = false;
        working_directory = "current_project_directory";
      };

      lsp = {
        eslint = {
          settings = {
            workingDirectory = { mode = "auto"; };
          };
        };
        psalm = {
          binary = { path = "psalm-wrapper"; };
          settings = {
            require_config_file = true;
          };
        };
      };

      languages = {
        PHP = {
          language_servers = [ "phpactor" "psalm" "..." ];
          formatter = {
            external = {
              command = "php-cs-fixer-wrapper";
              arguments = [ "--stdin-filepath" "{buffer_path}" ];
            };
          };
        };
      };
    };
  };
}
