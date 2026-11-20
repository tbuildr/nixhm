{...}: {
  flake.homeModules.editor = {pkgs, ...}: {
    programs.nvf = {
      enable = true;
      enableManpages = true;

      settings.vim = {
        # Handle SUPER+C copy in nvim to align with Niri settings
        # Lua hook: when a mouse selection finishes in Neovim Visual mode,
        # copy the selected text into Wayland's primary selection.
        # This allows Niri's global Super+C binding to copy Neovim selections
        # in the same way it copies highlighted text from other applications.

        luaConfigRC.copyMouseSelectionToPrimary = ''
          local copy_mouse_selection_ns =
            vim.api.nvim_create_namespace("copy-mouse-selection-to-primary")

          vim.on_key(function(key, typed)
            local input = typed ~= "" and typed or key

            if vim.fn.keytrans(input) ~= "<LeftRelease>" then
              return
            end

            vim.schedule(function()
              local mode = vim.fn.mode()

              if mode == "v" or mode == "V" or mode == "\22" then
                vim.cmd([[normal! "*ygv]])
              end
            end)
          end, copy_mouse_selection_ns)
        '';

        # ------------------------------------------------------------
        # Hardening: keep sensitive file contents off disk
        # ------------------------------------------------------------

        # Persistent undo is enabled below, but undo files store the full
        # edit history in plain text under ~/.local/state/nvim/undo/.
        # Disable it (plus swap/backup/shada history) for buffers that are
        # likely to contain secrets, and for sudoedit/temp files.
        luaConfigRC.noUndoForSecrets = ''
          local sensitive_patterns = {
            "/tmp/*",
            "/var/tmp/*",
            "/dev/shm/*",
            "*.env",
            "*.env.*",
            ".env",
            "*.age",
            "*.pem",
            "*.key",
            "*/.ssh/*",
            "*/.gnupg/*",
            "*/.password-store/*",
            "*/.passage/*",
            "*/secrets/*",
          }

          vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
            group = vim.api.nvim_create_augroup("no-undo-for-secrets", { clear = true }),
            pattern = sensitive_patterns,
            callback = function()
              vim.opt_local.undofile = false
              vim.opt_local.swapfile = false
              vim.opt_local.backup = false
              vim.opt_local.writebackup = false
              -- Don't record marks/registers/history for this session's shada.
              vim.opt.shadafile = "NONE"
            end,
          })
        '';

        # Allow `vi`, `vim` and `nvim` to start NVF.
        viAlias = true;
        vimAlias = true;

        # Basic editor behaviour.
        lineNumberMode = "relNumber";
        # Sets ignorecase + smartcase.
        searchCase = "smart";
        preventJunkFiles = true;

        undoFile.enable = true;

        globals = {
          mapleader = " ";
          maplocalleader = ",";
        };

        opts = {
          expandtab = true;
          tabstop = 2;
          softtabstop = 2;
          shiftwidth = 2;

          # smartindent removed: treesitter indentation handles this.

          splitbelow = true;
          splitright = true;

          cursorline = true;
          signcolumn = "yes";
          scrolloff = 8;

          updatetime = 200;
          timeoutlen = 300;
        };

        # Your Niri desktop uses Wayland.
        clipboard = {
          enable = true;
          registers = "unnamedplus";
          providers.wl-copy.enable = true;
        };

        # LazyVim's current default colour scheme.
        theme = {
          enable = true;
          name = "tokyonight";
          style = "moon";
          transparent = false;
        };

        # ------------------------------------------------------------
        # Language support
        # ------------------------------------------------------------

        lsp = {
          enable = true;
          formatOnSave = true;

          lightbulb.enable = true;
          trouble.enable = true;

          # Noice provides signature help, so lsp_signature isn't needed.
          lspSignature.enable = false;
        };

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          nix.enable = true;
          bash.enable = true;
          clang.enable = true;
          lua.enable = true;
          markdown.enable = true;
          json.enable = true;
          toml.enable = true;

          # Re-enable if you still edit fish scripts.
          # fish.enable = true;

          # Enable these when you need them:
          #
          # typescript.enable = true;
          # html.enable = true;
          # css.enable = true;
          # python.enable = true;
          # docker.enable = true;
          # yaml.enable = true;
        };

        treesitter = {
          enable = true;
          context.enable = true;
        };

        # ------------------------------------------------------------
        # Completion and editing
        # ------------------------------------------------------------

        autocomplete = {
          nvim-cmp.enable = false;

          blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
          };
        };

        snippets.luasnip.enable = true;

        autopairs.nvim-autopairs.enable = true;

        comments.comment-nvim.enable = true;

        notes.todo-comments.enable = true;

        utility = {
          surround.enable = true;
          diffview-nvim.enable = true;

          motion.leap.enable = true;

          # Yazi file manager integration.
          # Opens Yazi in a floating window inside Neovim.
          yazi-nvim = {
            enable = true;

            mappings = {
              # Open Yazi focused on the current file.
              openYazi = "<leader>y";

              # Open Yazi in Neovim's current working directory.
              openYaziDir = "<leader>Y";

              # Reopen the previous Yazi session.
              yaziToggle = "<C-Up>";
            };

            setupOpts = {
              # Keep Neo-tree as the handler when opening directories with `nvim .`.
              open_for_directories = false;

              floating_window_scaling_factor = 0.9;
              yazi_floating_window_border = "rounded";
            };
          };

          # Initialise Snacks, which is also used by yazi.nvim.
          snacks-nvim = {
            enable = true;

            setupOpts = {
              # Use Snacks for Neovim notifications.
              notifier.enabled = true;

              # We are not currently using Snacks for inline image rendering.
              image.enabled = false;
            };
          };
        };

        # ------------------------------------------------------------
        # Navigation
        # ------------------------------------------------------------

        filetree.neo-tree.enable = true;

        telescope.enable = true;

        binds.whichKey.enable = true;

        tabline.nvimBufferline.enable = true;

        # ------------------------------------------------------------
        # Git and terminal integration
        # ------------------------------------------------------------

        git = {
          gitsigns = {
            enable = true;

            # Avoids enabling the older null-ls integration.
            codeActions.enable = false;
          };
        };

        terminal.toggleterm = {
          enable = true;

          lazygit = {
            enable = true;

            # With your leader set to Space: Space g g
            mappings.open = "<leader>gg";

            # Opens LazyGit over the Neovim interface.
            direction = "float";
          };
        };

        # ------------------------------------------------------------
        # Appearance
        # ------------------------------------------------------------

        statusline.lualine.enable = true;

        dashboard.alpha.enable = true;

        # Embedded Lua: replace Alpha's default Neovim startup banner
        # with a custom character-based NVF logo.
        luaConfigRC.customAlphaLogo = ''
          local dashboard = require("alpha.themes.dashboard")

          dashboard.section.header.val = {
            [[                                                             ]],
            [[                 ███╗   ██╗██╗   ██╗███████╗                 ]],
            [[                 ████╗  ██║██║   ██║██╔════╝                 ]],
            [[                 ██╔██╗ ██║██║   ██║█████╗                   ]],
            [[                 ██║╚██╗██║╚██╗ ██╔╝██╔══╝                   ]],
            [[                 ██║ ╚████║ ╚████╔╝ ██║                      ]],
            [[                 ╚═╝  ╚═══╝  ╚═══╝  ╚═╝                      ]],
            [[                                                             ]],
            [[              N I X  V I M  F R A M E W O R K                ]],
            [[                                                             ]],
          }

          dashboard.section.header.opts.hl = "Type"
        '';

        visuals = {
          nvim-web-devicons.enable = true;
          # nvim-cursorline removed: illuminate handles word highlighting
          # and opts.cursorline handles the line highlight.
          fidget-nvim.enable = true;
          indent-blankline.enable = true;
        };

        # Replaced by snacks notifications
        notify.nvim-notify.enable = false;

        ui = {
          borders.enable = true;

          noice = {
            enable = true;

            setupOpts = {
              # Fidget shows LSP progress; avoid duplicate messages.
              lsp.progress.enabled = false;

              # Snacks owns vim.notify; stop noice overriding it.
              notify.enabled = false;
            };
          };

          illuminate.enable = true;
        };

        # ------------------------------------------------------------
        # LazyVim-style leader mappings
        # ------------------------------------------------------------

        keymaps = [
          # Copy selected text to the system clipboard and keep the selection.
          # (<C-S-c> removed: kitty intercepts ctrl+shift+c for its own copy.)
          {
            key = "<C-c>";
            mode = ["x" "s"];
            action = ''"+ygv'';
            desc = "Copy selection to system clipboard";
            silent = true;
          }

          # Paste after the cursor in Normal mode.
          {
            key = "<C-v>";
            mode = "n";
            action = ''"+p'';
            desc = "Paste from clipboard";
            silent = true;
          }

          # Replace a visual selection with clipboard contents.
          {
            key = "<C-v>";
            mode = "v";
            action = ''"+P'';
            desc = "Paste over selection";
            silent = true;
          }

          # Paste while typing. (Use <C-q> for Vim's insert-literal.)
          {
            key = "<C-v>";
            mode = "i";
            action = "<C-r>+";
            desc = "Paste from clipboard";
            silent = true;
          }

          # Paste on the command line.
          {
            key = "<C-v>";
            mode = "c";
            action = "<C-r>+";
            desc = "Paste from clipboard";
            silent = true;
          }

          # Ctrl+V normally enters Visual Block mode, so retain it elsewhere.
          {
            key = "<leader>v";
            mode = "n";
            action = "<C-v>";
            desc = "Visual block mode";
            silent = true;
          }

          {
            key = "<leader>e";
            mode = "n";
            action = "<cmd>Neotree toggle<CR>";
            desc = "Toggle explorer";
          }

          {
            key = "<leader>ff";
            mode = "n";
            action = "<cmd>Telescope find_files<CR>";
            desc = "Find files";
          }

          {
            key = "<leader>fg";
            mode = "n";
            action = "<cmd>Telescope live_grep<CR>";
            desc = "Search text";
          }

          {
            key = "<leader>fb";
            mode = "n";
            action = "<cmd>Telescope buffers<CR>";
            desc = "Find buffers";
          }

          {
            key = "<leader>fr";
            mode = "n";
            action = "<cmd>Telescope oldfiles<CR>";
            desc = "Recent files";
          }

          {
            key = "<leader>xx";
            mode = "n";
            action = "<cmd>Trouble diagnostics toggle<CR>";
            desc = "Diagnostics";
          }

          {
            key = "<S-h>";
            mode = "n";
            action = "<cmd>BufferLineCyclePrev<CR>";
            desc = "Previous buffer";
          }

          {
            key = "<S-l>";
            mode = "n";
            action = "<cmd>BufferLineCycleNext<CR>";
            desc = "Next buffer";
          }

          {
            key = "<leader>bd";
            mode = "n";
            action = "<cmd>bdelete<CR>";
            desc = "Delete buffer";
          }

          {
            key = "<Esc>";
            mode = "n";
            action = "<cmd>nohlsearch<CR>";
            desc = "Clear search highlighting";
          }
        ];
      };
    };
  };
}
