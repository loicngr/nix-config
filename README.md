# NixOS Configuration

Configuration NixOS personnelle pour une station de travail de développement web avec GNOME et support NVIDIA.

## Structure

```
.
├── AGENTS.md                  # Instructions agents IA
├── CLAUDE.md                  # Référence vers AGENTS.md
├── flake.nix                  # Point d'entrée Nix Flakes
├── configuration.nix          # Configuration système principale
├── copy-from-nixos.sh         # Synchronisation depuis /etc/nixos
├── copy-to-nixos.sh           # Synchronisation vers /etc/nixos
├── home-manager/
│   └── loicngr.nix            # Configuration utilisateur (Home Manager)
├── modules/
│   ├── nvidia.nix             # Configuration GPU NVIDIA (Intel/NVIDIA hybrid)
│   ├── php.nix                # Environnements PHP 8.2 / 8.3
│   └── zsh.nix                # Configuration ZSH et Oh My ZSH
└── scripts/
    ├── claude-commit.sh       # Génération de messages de commit avec Claude
    ├── claude-merge.sh        # Résolution de conflits merge avec Claude
    ├── eslint-wrapper.sh      # Wrapper ESLint pour Neovim
    ├── php-cs-fixer-wrapper.sh # Wrapper PHP-CS-Fixer pour Neovim
    ├── phpstan-wrapper.sh     # Wrapper PHPStan pour Neovim
    ├── phpunit-run.sh         # Lancer PHPUnit depuis Neovim
    └── tmux-project.sh        # Sessions tmux par projet
```

## Fichiers Nix

### `flake.nix`

Point d'entrée du système. Définit les inputs et outputs du flake.

**Inputs :**
| Input | Description |
|-------|-------------|
| `nixpkgs` | NixOS 25.11 (stable) |
| `nixpkgs-unstable` | Paquets instables (PhpStorm, lazygit, yazi) |
| `home-manager` | Release 25.11 |
| `stylix` | Thème Home Manager |
| `claude-code` | Claude Code CLI |
| `codex-cli-nix` | Codex CLI |

**Outputs :**
- `nixosConfigurations.loicngr` - Configuration système
- `homeConfigurations.loicngr` - Configuration Home Manager

---

### `configuration.nix`

Configuration système principale NixOS.

**Sections :**

| Section | Description |
|---------|-------------|
| Bootloader | systemd-boot, EFI |
| Réseau | NetworkManager, hostname `loicngr` |
| Locale | `fr_FR.UTF-8`, timezone `Europe/Paris` |
| Desktop | GNOME + GDM (Wayland) |
| Audio | Pipewire |
| Virtualisation | Docker |
| Utilisateur | `loicngr` (wheel, docker, kvm, adbusers, gamemode) |

**Paquets système installés :**

| Catégorie | Paquets                                                                                                                                      |
|-----------|----------------------------------------------------------------------------------------------------------------------------------------------|
| Éditeurs | vim, vscodium                                                                                                                                |
| Terminal | kitty, bat, btop, eza, fd, fzf, htop, ripgrep, yazi, lazygit, lazydocker                                                                     |
| Build tools | gcc, gnumake, autoconf, automake, libtool, pkg-config                                                                                        |
| Node.js | fnm, eslint, eslint_d, prettierd, typescript                                                                                                 |
| LSP | typescript-language-server, vue-language-server (2.2.12), yaml-language-server, bash-language-server, helm-ls, marksman, rust-analyzer, sqls |
| PHP | PHP 8.2/8.3, Composer, PHP-CS-Fixer, phpactor, symfony-cli                                                                                   |
| Python | Python 3.14                                                                                                                                  |
| Java | OpenJDK 17                                                                                                                                   |
| BDD | MariaDB, PostgreSQL, RabbitMQ-C                                                                                                              |
| Autre | vlc, ffmpeg, insomnia, parsec-bin                                                                                                            |

**Override personnalisé :**
```nix
# Vue Language Server 2.2.12 (dernière version supportant Vue 2)
vue-language-server-vue2 = pkgs.vue-language-server.overrideAttrs (...)
```

**Services :**
- MySQL (MariaDB)
- PostgreSQL

**nix-ld :** Compatibilité binaires Linux (Electron, Cypress, SDL, etc.)

---

### `modules/php.nix`

Définit les environnements PHP 8.2 et 8.3 avec extensions.

**Extensions incluses :**
```
amqp, gd, pdo, dom, ast, yaml, intl, xdebug, curl, apcu, exif,
pgsql, iconv, sodium, mysqli, sqlite3, openssl, imagick, mbstring,
calendar, xmlwriter, xmlreader, tokenizer, simplexml, pdo_mysql,
pdo_pgsql, pdo_sqlite, ctype, filter, session
```

**Configuration PHP :**
```ini
xdebug.mode=develop
memory_limit = 2G
```

**Exports :** `myPhp82`, `myPhp83` (utilisés dans zsh.nix et configuration.nix)

---

### `modules/nvidia.nix`

Configuration GPU hybride Intel/NVIDIA Prime.

| Option | Valeur |
|--------|--------|
| Mode | Prime Offload |
| Driver | Open source (Turing+) |
| Intel Bus ID | `PCI:0@0:2:0` |
| NVIDIA Bus ID | `PCI:1@0:0:0` |
| Power Management | Désactivé |

---

### `modules/zsh.nix`

Configuration ZSH avec Oh My ZSH.

**Plugins Oh My ZSH :**
```
git, npm, node, z, docker, sudo, kubectl, history, helm, fzf
```

**Alias :**
| Alias | Commande |
|-------|----------|
| `ll`, `lla`, `la`, `ls` | eza |
| `cat` | bat |
| `nu` | Rebuild NixOS + Home Manager |
| `nup` | Update flake + rebuild |
| `nd` | Garbage collect + rebuild |
| `ncg` | `nh clean all --ask` |
| `claudo` | Claude sans permissions |
| `ts` | Session tmux sekur (2x2) |
| `tp` | Session tmux propret (2x2) |
| `tn` | Session tmux nixos (2 splits) |
| `php82`, `php83` | PHP versions |
| `composer82`, `composer83` | Composer versions |

**Fonctions :**
- `use-php82` / `use-php83` - Changer de version PHP
- `export_app_name_from_env` - Auto-export APP_NAME depuis .env
- Initialisation fnm avec auto-switch

---

### `home-manager/loicngr.nix`

Configuration utilisateur Home Manager.

**Paquets utilisateur :**
| Catégorie | Paquets |
|-----------|---------|
| IA | claude-code, codex |
| Gaming | prismlauncher, mangohud |
| Tools | cordova, gradle, bun, uv |
| Apps | keepassxc, wkhtmltopdf, gradia, element-desktop |
| K8s | k9s, kubectl, kubernetes-helm, minikube |
| GNOME | gnome-tweaks, dash-to-panel, appindicator, clipboard-indicator, forge |
| IDE | PhpStorm (unstable), Android Studio |

**Scripts wrapper :**

| Script | Description |
|--------|-------------|
| `eslint-wrapper` | Trouve automatiquement la config ESLint et utilise eslint_d |
| `php-cs-fixer-wrapper` | Formateur PHP via stdin |
| `phpstan-wrapper` | PHPStan avec détection auto de config |
| `phpunit-run` | Lance PHPUnit depuis Neovim (méthode ou fichier) |
| `claude-commit` | Génère un message de commit avec Claude (haiku) |
| `claude-merge` | Résolution de conflits merge assistée par Claude |
| `tmux-project` | Sessions tmux par projet (sekur, propret, nixos) |

**Configuration NvChad (Neovim) :**

Éditeur principal avec LSP complet via NvChad.

**Autres programmes :**
- **Git** - user.name, user.email, pull.rebase, core.editor=micro
- **Kitty** - JetBrains Mono, splits, remote control
- **bat** - Catppuccin Mocha theme
- **eza** - Catppuccin theme, icons, git
- **gh** - GitHub CLI avec credential helper

**dconf GNOME :**
| Raccourci | Action |
|-----------|--------|
| `Super+T` | Kitty |
| `Super+B` | Chrome |
| `Shift+Super+S` | Gradia screenshot |
| `Print` | Gradia screenshot |

**Lazygit :**

| Raccourci | Action |
|-----------|--------|
| `C` | Générer un message de commit avec Claude (haiku) |
| `M` | Merge --no-ff --no-commit avec résolution Claude |

**tmux :**

| Plugin | Description |
|--------|-------------|
| resurrect | Sauvegarde/restauration de sessions |
| yank | Copier dans le clipboard système |
| fingers | Sélection rapide d'URLs, IPs, hashs |
| tmux-fzf | Gestion sessions/windows avec fzf |
| catppuccin | Thème Catppuccin Mocha |

**Forge (tiling window manager) :**

Extensions activées automatiquement via dconf : dash-to-panel, appindicator, clipboard-indicator, forge.

| Raccourci | Action |
|-----------|--------|
| `Super+Left/Right/Up/Down` | Focus fenêtre dans la direction |
| `Shift+Super+Left/Right/Up/Down` | Déplacer fenêtre |
| `Ctrl+Super+Left/Right/Up/Down` | Swap fenêtres |
| `Ctrl+Shift+Super+Left/Right/Up/Down` | Resize (agrandir dans la direction) |
| `Super+G` | Toggle split horizontal/vertical |
| `Super+Z` | Split horizontal |
| `Super+V` | Split vertical |
| `Shift+Super+S` | Toggle stacked layout |
| `Shift+Super+T` | Toggle tabbed layout |
| `Super+C` | Toggle floating |
| `Shift+Super+C` | Toggle always floating |
| `Super+W` | Toggle tiling |
| `Super+Return` | Swap last active |
| `Super+.` | Préférences Forge |

**Autostart :**
- kDrive (AppImage)
- Element Desktop

---

## Utilisation

### Reconstruction du système
```bash
# Copier vers /etc/nixos et rebuild
sudo cp *.nix /etc/nixos/ && sudo cp -r modules home-manager /etc/nixos/
sudo nixos-rebuild switch --flake /etc/nixos#loicngr

# Ou via alias
nu    # Rebuild seulement
nup   # Update + rebuild
```

### Home Manager
```bash
home-manager switch --flake /etc/nixos#loicngr
```

### Changement de version PHP
```bash
use-php82   # Activer PHP 8.2
use-php83   # Activer PHP 8.3

# Ou directement
php82 -v
composer83 install
```

### Nettoyage
```bash
nd    # Garbage collect 30j + rebuild
ncg   # nh clean interactif
```

## Synchronisation

```bash
./copy-to-nixos.sh     # Copier vers /etc/nixos
./copy-from-nixos.sh   # Copier depuis /etc/nixos
```

> **Note:** Ce dépôt est une copie des fichiers utilisés par le système (dans `/etc/nixos`).
> Avant d'appliquer une modification, il faut recopier manuellement les fichiers dans `/etc/nixos` aux bons emplacements.
