{ pkgs, ... }:

{
  programs.nvchad = {
    enable = true;
    hm-activation = true;
    backup = true;

    extraPlugins = ''
      return {
        {
          "kdheepak/lazygit.nvim",
          cmd = "LazyGit",
          dependencies = { "nvim-lua/plenary.nvim" },
        },
        {
          "mikavilpas/yazi.nvim",
          event = "VeryLazy",
          opts = {
            open_for_directories = true,
          },
        },
        {
          "j-hui/fidget.nvim",
          event = "LspAttach",
          opts = {},
        },
      }
    '';

    extraConfig = ''
      -- LSP servers configuration
      local vue_ls_exe = vim.fn.exepath("vue-language-server")
      local vue_ts_plugin = nil
      local vue_ts_plugin_probe = nil
      if vue_ls_exe ~= "" then
        local vue_ls_root = vim.fn.fnamemodify(vue_ls_exe, ":p:h:h")
        local candidate = vue_ls_root .. "/lib/language-tools/packages/typescript-plugin"
        if vim.uv.fs_stat(candidate) then
          vue_ts_plugin = candidate

          -- tsserver expects plugin names to resolve from a node_modules tree.
          local probe_root = vim.fn.stdpath("cache") .. "/tsserver-vue-plugin-probe"
          local plugin_link = probe_root .. "/node_modules/@vue/typescript-plugin"
          local uv = vim.uv or vim.loop
          vim.fn.mkdir(probe_root .. "/node_modules/@vue", "p")

          if not uv.fs_stat(plugin_link) then
            -- cleanup dangling path if present, then create symlink
            pcall(vim.fn.delete, plugin_link, "rf")
            pcall(uv.fs_symlink, vue_ts_plugin, plugin_link)
          end

          if uv.fs_stat(plugin_link) then
            vue_ts_plugin_probe = probe_root
          end
        end
      end

      vim.lsp.config("phpactor", {
        cmd = { "phpactor", "language-server" },
        filetypes = { "php" },
        root_markers = { ".phpactor.json" },
        workspace_required = true,
      })

      vim.lsp.config("vue_ls", {
        cmd = { "vue-language-server", "--stdio" },
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json" },
        init_options = {
          typescript = {
            tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib",
          },
          vue = {
            hybridMode = true,
          },
        },
        settings = {
          typescript = {
            tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib",
          },
          vue = {
            hybridMode = true,
          },
        },
      })

      vim.lsp.config("ts_ls", {
        cmd = { "typescript-language-server", "--stdio" },
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json" },
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
          "vue",
        },
        init_options = {
          hostInfo = "neovim",
          tsserver = {
            path = "${pkgs.typescript}/lib/node_modules/typescript/lib/tsserver.js",
            fallbackPath = "${pkgs.typescript}/lib/node_modules/typescript/lib/tsserver.js",
          },
          plugins = vue_ts_plugin and {
            {
              name = "@vue/typescript-plugin",
              location = vue_ts_plugin_probe or vue_ts_plugin,
              languages = { "javascript", "typescript", "vue" },
            },
          } or {},
        },
      })

      vim.lsp.config("dockerls", {
        cmd = { "docker-langserver", "--stdio" },
      })

      vim.lsp.config("yamlls", {
        cmd = { "yaml-language-server", "--stdio" },
      })

      vim.lsp.config("bashls", {
        cmd = { "bash-language-server", "start" },
      })

      vim.lsp.config("jsonls", {
        cmd = { "vscode-json-language-server", "--stdio" },
      })

      vim.lsp.config("helm_ls", {
        cmd = { "helm_ls", "serve" },
      })

      vim.lsp.config("marksman", {
        cmd = { "marksman", "server" },
      })

      vim.lsp.config("rust_analyzer", {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml" },
        workspace_required = true,
      })

      vim.lsp.config("sqls", {
        cmd = { "sqls" },
      })

      vim.lsp.enable({
        "phpactor", "ts_ls", "vue_ls", "dockerls", "yamlls",
        "bashls", "jsonls", "helm_ls", "marksman", "rust_analyzer", "sqls",
      })

      local function normalize_location(loc)
        if not loc then
          return nil
        end
        if loc.uri and loc.range then
          return {
            uri = loc.uri,
            line = loc.range.start.line,
            character = loc.range.start.character,
            encoding = "utf-16",
          }
        end
        if loc.targetUri and loc.targetSelectionRange then
          return {
            uri = loc.targetUri,
            line = loc.targetSelectionRange.start.line,
            character = loc.targetSelectionRange.start.character,
            encoding = "utf-16",
          }
        end
        return nil
      end

      local function useful_lsp_location(loc)
        local nloc = normalize_location(loc)
        if not nloc then
          return false
        end
        local bufnr = vim.api.nvim_get_current_buf()
        local cur = vim.api.nvim_win_get_cursor(0)
        local cur_uri = vim.uri_from_bufnr(bufnr)
        if nloc.uri == cur_uri and nloc.line == (cur[1] - 1) then
          return false
        end
        return true
      end

      local function extract_import_path()
        local line = vim.api.nvim_get_current_line()
        if line:match("^%s*import%s") then
          local from_path = line:match("from%s+['\"]([^'\"]+)['\"]")
          if from_path then
            return from_path
          end
          local side_effect_path = line:match("^%s*import%s+['\"]([^'\"]+)['\"]")
          if side_effect_path then
            return side_effect_path
          end
        end

        local col = vim.api.nvim_win_get_cursor(0)[2] + 1
        local init = 1
        while true do
          local s, e, quoted = line:find("['\"]([^'\"]+)['\"]", init)
          if not s then
            break
          end
          if col >= s and col <= e then
            return quoted
          end
          init = e + 1
        end
        return nil
      end

      local function resolve_import_path(import_path)
        if not import_path then
          return nil
        end

        local buf_path = vim.api.nvim_buf_get_name(0)
        local root = vim.fs.root(buf_path, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
        if not root then
          return nil
        end

        local rel = nil
        if vim.startswith(import_path, "@/") then
          rel = "src/" .. import_path:sub(3)
        elseif vim.startswith(import_path, "components/") then
          rel = "src/components/" .. import_path:sub(#"components/" + 1)
        elseif vim.startswith(import_path, "layouts/") then
          rel = "src/layouts/" .. import_path:sub(#"layouts/" + 1)
        elseif vim.startswith(import_path, "pages/") then
          rel = "src/pages/" .. import_path:sub(#"pages/" + 1)
        elseif vim.startswith(import_path, "assets/") then
          rel = "src/assets/" .. import_path:sub(#"assets/" + 1)
        elseif vim.startswith(import_path, "boot/") then
          rel = "src/boot/" .. import_path:sub(#"boot/" + 1)
        elseif vim.startswith(import_path, "src/") then
          rel = import_path
        elseif vim.startswith(import_path, "./") or vim.startswith(import_path, "../") then
          local base = vim.fs.dirname(buf_path)
          rel = vim.fs.normalize(base .. "/" .. import_path)
        end

        if not rel then
          return nil
        end

        local base = rel
        if not vim.startswith(base, "/") then
          base = root .. "/" .. base
        end

        local candidates = {
          base,
          base .. ".vue",
          base .. ".js",
          base .. ".ts",
          base .. ".jsx",
          base .. ".tsx",
          base .. "/index.vue",
          base .. "/index.js",
          base .. "/index.ts",
        }

        local uv = vim.uv or vim.loop
        for _, p in ipairs(candidates) do
          local st = uv.fs_stat(p)
          if st and st.type == "file" then
            return p
          end
        end
        return nil
      end

      local function goto_definition_with_import_fallback()
        local params = vim.lsp.util.make_position_params(0, "utf-16")
        local result = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 2000) or {}
        local locations = {}
        for _, response in pairs(result) do
          if response and response.result then
            if vim.islist(response.result) then
              vim.list_extend(locations, response.result)
            else
              table.insert(locations, response.result)
            end
          end
        end

        for _, loc in ipairs(locations) do
          if useful_lsp_location(loc) then
            local nloc = normalize_location(loc)
            if nloc then
              vim.lsp.util.show_document({
                uri = nloc.uri,
                range = {
                  start = { line = nloc.line, character = nloc.character },
                  ["end"] = { line = nloc.line, character = nloc.character },
                },
              }, nloc.encoding, { focus = true })
              return
            end
          end
        end

        local import_path = extract_import_path()
        local resolved = resolve_import_path(import_path)
        if resolved then
          vim.cmd("edit " .. vim.fn.fnameescape(resolved))
          return
        end

        vim.notify("Definition introuvable", vim.log.levels.WARN)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          vim.keymap.set("n", "gd", goto_definition_with_import_fallback, {
            buffer = args.buf,
            desc = "LSP definition with import fallback",
            silent = true,
          })
        end,
      })

      -- Conform.nvim : format on save + formatters
      require("conform").setup({
        formatters_by_ft = {
          php = { "php_cs_fixer_wrapper" },
          javascript = { "eslint_wrapper" },
          typescript = { "eslint_wrapper" },
          vue = { "eslint_wrapper" },
          jsx = { "eslint_wrapper" },
          tsx = { "eslint_wrapper" },
          nix = { "nixfmt" },
          lua = { "stylua" },
        },
        format_on_save = {
          timeout_ms = 3000,
          lsp_fallback = true,
        },
        formatters = {
          eslint_wrapper = {
            command = "eslint-wrapper",
            args = { "--stdin-filename", "$FILENAME" },
            stdin = true,
          },
          php_cs_fixer_wrapper = {
            command = "php-cs-fixer-wrapper",
            stdin = true,
          },
          nixfmt = {
            command = "${pkgs.nixfmt}/bin/nixfmt",
          },
        },
      })

      local map = vim.keymap.set

      -- NvimTree : ouvrir + cibler le fichier actif
      map("n", "<leader>e", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "NvimTree find file toggle" })

      -- LazyGit
      map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

      -- Yazi file picker
      map("n", "<C-e>", "<cmd>Yazi<CR>", { desc = "Yazi file picker" })

      -- Move lines up/down
      map("n", "<A-Down>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
      map("n", "<A-Up>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
      map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
      map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
      map("i", "<A-Down>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
      map("i", "<A-Up>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })

      -- Jump backward/forward
      map("n", "<A-Left>", "<C-o>", { desc = "Jump backward" })
      map("n", "<A-Right>", "<C-i>", { desc = "Jump forward" })

      -- Format
      map("n", "<C-A-l>", function() vim.lsp.buf.format() end, { desc = "LSP Format" })

      -- Match brackets
      map("n", "<A-m>", "%", { desc = "Match bracket" })

      -- Paragraph navigation
      map("n", "<C-Up>", "{", { desc = "Previous paragraph" })
      map("n", "<C-Down>", "}", { desc = "Next paragraph" })

      -- Toggle comments (Ctrl+/ sends C-_ in most terminals)
      map("n", "<C-_>", "gcc", { desc = "Toggle comment", remap = true })
      map("v", "<C-_>", "gc", { desc = "Toggle comment", remap = true })
      map("n", "<C-/>", "gcc", { desc = "Toggle comment", remap = true })
      map("v", "<C-/>", "gc", { desc = "Toggle comment", remap = true })

      -- Global search
      map("n", "<A-f>", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })

      -- LSP
      map("n", "<C-b>", function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
      map("n", "<C-r>", function() vim.lsp.buf.references() end, { desc = "Go to references" })
      map("n", "<F2>", function() vim.diagnostic.goto_next() end, { desc = "Next diagnostic" })
      map("n", "<S-F2>", function() vim.diagnostic.goto_prev() end, { desc = "Previous diagnostic" })
      map("n", "<S-F6>", function() vim.lsp.buf.rename() end, { desc = "Rename symbol" })
      map("n", "<A-CR>", function() vim.lsp.buf.code_action() end, { desc = "Code action" })
      map("n", "<C-q>", function() vim.lsp.buf.hover() end, { desc = "Hover documentation" })
      map({ "n", "i" }, "<C-p>", function() vim.lsp.buf.signature_help() end, { desc = "Signature help" })

      -- Buffers
      map("n", "<A-e>", "<cmd>Telescope buffers<CR>", { desc = "Buffer picker" })

      -- Undo/Redo
      map("n", "<C-z>", "u", { desc = "Undo" })
      map("n", "<A-z>", "<C-r>", { desc = "Redo" })
      map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
      map("i", "<A-z>", "<C-o><C-r>", { desc = "Redo" })

      -- Duplicate line
      map("n", "<C-d>", "<cmd>t.<CR>", { desc = "Duplicate line" })

      -- Delete line / selection
      map("n", "<C-y>", "dd", { desc = "Delete line" })
      map("v", "<C-y>", "d", { desc = "Delete selection" })

      -- Scroll without moving cursor
      map("n", "<C-A-Up>", "<C-y>", { desc = "Scroll up" })
      map("n", "<C-A-Down>", "<C-e>", { desc = "Scroll down" })

      -- Select all
      map("n", "<C-a>", "ggVG", { desc = "Select all" })

      -- Go to line
      map("n", "<C-g>", ":", { desc = "Go to line" })

      -- Symbol picker
      map("n", "<A-o>", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document symbols" })

      -- Splits
      map("n", "<C-A-d>", "<cmd>split<CR>", { desc = "Horizontal split" })
      map("n", "<C-A-r>", "<cmd>vsplit<CR>", { desc = "Vertical split" })

      -- Search
      map("n", "<C-f>", "/", { desc = "Search" })

      -- Save
      map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save" })
      map("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save and exit insert" })

      -- Word navigation
      map("n", "<C-Left>", "b", { desc = "Previous word" })
      map("n", "<C-Right>", "w", { desc = "Next word" })
      map("i", "<C-Left>", "<C-o>b", { desc = "Previous word" })
      map("i", "<C-Right>", "<C-o>w", { desc = "Next word" })

      -- Phpactor : clear cache + restart LSP
      map("n", "<leader>pi", function()
        vim.fn.delete(vim.fn.expand("~/.cache/phpactor"), "rf")
        vim.cmd("LspRestart phpactor")
        vim.notify("Phpactor: cache vidé + LSP redémarré")
      end, { desc = "Phpactor reset" })

      -- PHPUnit tests (via tmux split)
      map("n", "<leader>tt", function()
        local file = vim.fn.expand("%")
        local line = vim.fn.line(".")
        vim.fn.jobstart("tmux split-window -v 'phpunit-run method " .. file .. " " .. line .. "; read'")
      end, { desc = "PHPUnit test method" })
      map("n", "<leader>tf", function()
        local file = vim.fn.expand("%")
        vim.fn.jobstart("tmux split-window -v 'phpunit-run file " .. file .. "; read'")
      end, { desc = "PHPUnit test file" })
    '';
  };
}
