{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      #theme = "base16";
      editor = {
        default-yank-register = "+";

        auto-save = {
          focus-lost = true;
          after-delay.enable = true;
        };

        mouse = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        indent-guides = {
          render = true;
          character = "│";
        };

        whitespace.render = "all";

        lsp = {
          display-messages = true;
          display-inlay-hints = false;
        };

        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];
          center = [ ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-type"
          ];
        };

        bufferline = "multiple";
        color-modes = true;
        trim-trailing-whitespace = true;

        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "error";
        };

        file-picker = {
          hidden = false;
          git-ignore = false;
          git-global = false;
          ignore = true;
        };

      };

      keys.normal = {
        "space" = {
          "t" = {
            "t" =
              ":sh kitty @ launch --location=hsplit --hold --cwd=current phpunit-helix method %{buffer_name} %{cursor_line}";
            "f" = ":sh kitty @ launch --location=hsplit --hold --cwd=current phpunit-helix file %{buffer_name}";
          };
        };

        "A-up" = [
          "extend_line_below"
          "delete_selection"
          "move_line_up"
          "paste_before"
          "collapse_selection"
          "goto_line_start"
        ];
        "A-down" = [
          "extend_line_below"
          "delete_selection"
          "move_line_down"
          "paste_before"
          "collapse_selection"
          "goto_line_start"
        ];
        "A-left" = "jump_backward";
        "A-right" = "jump_forward";
        "C-A-l" = ":format";
        "A-m" = "match_brackets";
        "C-up" = "goto_prev_paragraph";
        "C-down" = "goto_next_paragraph";
        "C-S-up" = "goto_prev_function";
        "C-S-down" = "goto_next_function";
        "C-/" = "toggle_comments";
        "A-f" = "global_search";
        "C-b" = "goto_definition";
        "C-r" = "goto_reference";
        # Next/Previous error (F2 / Shift+F2)
        "F2" = "goto_next_diag";
        "S-F2" = "goto_prev_diag";
        "S-F6" = "rename_symbol";
        # Quick fix / Code actions (Alt+Enter)
        "A-ret" = "code_action";
        # Documentation popup (Ctrl+Q)
        "C-q" = "hover";
        # Parameter info (Ctrl+P) - signature help
        "C-p" = "signature_help";
        # Buffer picker (onglets)
        "A-e" = "buffer_picker";
        # Undo/Redo
        "C-z" = "undo";
        "A-z" = "redo";
        # Dupliquer ligne
        "C-d" = [
          "extend_line_below"
          "yank"
          "paste_after"
        ];
        # Sélectionner tout
        "C-a" = "select_all";
        # Aller à la ligne
        "C-g" = "goto_line";
        # Symboles du document
        "A-o" = "symbol_picker";
        "C-A-d" = "hsplit";
        "C-A-r" = "vsplit";
        "C-f" = "search";
        "C-w" = ":buffer-close";
        "C-left" = "move_prev_word_start";
        "C-right" = "move_next_word_start";
        # Yazi file picker
        "C-e" = [
          ":sh rm -f /tmp/yazi-chooser"
          '':insert-output yazi "%{buffer_name}" --chooser-file=/tmp/yazi-chooser''
          '':insert-output echo "\x1b[?1049h\x1b[?2004h" > /dev/tty''
          ":open %sh{cat /tmp/yazi-chooser}"
          ":redraw"
        ];
      };

      keys.insert = {
        "C-s" = [
          ":write"
          "normal_mode"
        ];
        "C-z" = "undo";
        "A-z" = "redo";
        "C-left" = "move_prev_word_start";
        "C-right" = "move_next_word_start";
        "C-space" = "completion";
        "C-p" = "signature_help";
      };

      keys.select = {
        "C-/" = "toggle_comments";
        "A-up" = [
          "delete_selection"
          "move_line_up"
          "paste_before"
        ];
        "A-down" = [
          "delete_selection"
          "move_line_down"
          "paste_before"
        ];
      };
    };

    languages = {
      language-server = {
        vue-language-server = {
          command = "vue-language-server";
          args = [ "--stdio" ];
          config = {
            typescript = {
              tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib";
            };
            vue = {
              hybridMode = false;
            };
          };
        };
        typescript-language-server = {
          command = "typescript-language-server";
          args = [ "--stdio" ];
        };
        phpactor = {
          command = "phpactor";
          args = [ "language-server" ];
        };
        docker-langserver = {
          command = "docker-langserver";
          args = [ "--stdio" ];
        };
        yaml-language-server = {
          command = "yaml-language-server";
          args = [ "--stdio" ];
        };
        vscode-css-language-server = {
          command = "vscode-css-language-server";
          args = [ "--stdio" ];
        };
        bash-language-server = {
          command = "bash-language-server";
          args = [ "start" ];
        };
        vscode-html-language-server = {
          command = "vscode-html-language-server";
          args = [ "--stdio" ];
        };
        vscode-json-language-server = {
          command = "vscode-json-language-server";
          args = [ "--stdio" ];
        };
        helm-ls = {
          command = "helm_ls";
          args = [ "serve" ];
        };
        marksman = {
          command = "marksman";
          args = [ "server" ];
        };
        rust-analyzer = {
          command = "rust-analyzer";
        };
        sqls = {
          command = "sqls";
        };
      };

      language = [
        {
          name = "php";
          auto-format = true;
          language-servers = [ "phpactor" ];
          roots = [ "composer.json" ];
          formatter = {
            command = "php-cs-fixer-wrapper";
          };
        }
        {
          name = "javascript";
          auto-format = true;
          formatter = {
            command = "eslint-wrapper";
            args = [
              "--stdin-filename"
              "%{buffer_name}"
            ];
          };
          language-servers = [
            {
              name = "typescript-language-server";
              except-features = [ "format" ];
            }
          ];
        }
        {
          name = "typescript";
          auto-format = true;
          formatter = {
            command = "eslint-wrapper";
            args = [
              "--stdin-filename"
              "%{buffer_name}"
            ];
          };
        }
        {
          name = "vue";
          auto-format = true;
          roots = [ "package.json" ];
          formatter = {
            command = "eslint-wrapper";
            args = [
              "--stdin-filename"
              "%{buffer_name}"
            ];
          };
          language-servers = [
            {
              name = "vue-language-server";
              except-features = [ "format" ];
            }
          ];
        }
        {
          name = "jsx";
          auto-format = true;
          formatter = {
            command = "eslint-wrapper";
            args = [
              "--stdin-filename"
              "%{buffer_name}"
            ];
          };
        }
        {
          name = "tsx";
          auto-format = true;
          formatter = {
            command = "eslint-wrapper";
            args = [
              "--stdin-filename"
              "%{buffer_name}"
            ];
          };
        }
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        }
        {
          name = "dockerfile";
          language-servers = [ "docker-langserver" ];
        }
        {
          name = "yaml";
          auto-format = true;
          language-servers = [ "yaml-language-server" ];
        }
        {
          name = "css";
          auto-format = true;
          language-servers = [ "vscode-css-language-server" ];
        }
        {
          name = "scss";
          auto-format = true;
          language-servers = [ "vscode-css-language-server" ];
        }
        {
          name = "bash";
          auto-format = true;
          language-servers = [ "bash-language-server" ];
        }
        {
          name = "git-commit";
        }
        {
          name = "git-rebase";
        }
        {
          name = "git-config";
        }
        {
          name = "html";
          auto-format = true;
          language-servers = [ "vscode-html-language-server" ];
        }
        {
          name = "json";
          auto-format = true;
          language-servers = [ "vscode-json-language-server" ];
        }
        {
          name = "helm";
          auto-format = true;
          language-servers = [ "helm-ls" ];
        }
        {
          name = "markdown";
          auto-format = true;
          soft-wrap.enable = true;
          language-servers = [ "marksman" ];
        }
        {
          name = "rust";
          auto-format = true;
          language-servers = [ "rust-analyzer" ];
        }
        {
          name = "sql";
          language-servers = [ "sqls" ];
        }
      ];
    };

    themes = {
      #autumn_night_transparent = {
      #  "inherits" = "autumn_night";
      #  "ui.background" = { };
      #};
    };
  };

  xdg.configFile."helix/ignore".text = ''
    vendor/
    node_modules/
  '';
}
