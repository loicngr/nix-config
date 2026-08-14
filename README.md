# NixOS Configuration

Configuration NixOS personnelle pour une station de travail de développement web avec Niri (Wayland), Noctalia et support NVIDIA.

## Structure

```
.
├── CLAUDE.md                  # Instructions agents IA
├── flake.nix                  # Point d'entrée Nix Flakes
├── configuration.nix          # Configuration système principale
├── copy-from-nixos.sh         # Synchronisation depuis /etc/nixos
├── copy-to-nixos.sh           # Synchronisation vers /etc/nixos
├── config/
│   ├── lazygit/
│   │   └── commit-prompt.md   # Prompt pour commits IA
│   ├── lazyworktree/
│   │   └── config.yaml        # Config lazyworktree
│   └── noctalia/
│       └── v4-archive/        # Conf v4 archivée (réf. de re-tuning + données clipper)
├── home-manager/
│   ├── loicngr.nix            # Configuration utilisateur (Home Manager)
│   ├── niri.nix               # Niri + Noctalia + GTK/curseur
│   ├── kitty.nix              # Configuration terminal Kitty
│   └── zed.nix                # Éditeur Zed (extensions, LSP, thème, formatters)
├── modules/
│   ├── nvidia.nix             # Configuration GPU NVIDIA (Intel/NVIDIA hybrid)
│   ├── php.nix                # Environnements PHP 8.3 / 8.4 / 8.5
│   └── zsh.nix                # Configuration ZSH et Oh My ZSH
└── scripts/
    ├── claude-commit.sh       # Génération de messages de commit avec Claude
    ├── claude-merge.sh        # Résolution de conflits merge avec Claude
    ├── eslint-wrapper.sh      # Wrapper ESLint
    ├── php-cs-fixer-wrapper.sh # Wrapper PHP-CS-Fixer (auto-détection conf + binaire vendored)
    ├── phpstan-wrapper.sh     # Wrapper PHPStan (auto-détection conf + binaire vendored)
    ├── psalm-wrapper.sh       # Wrapper Psalm (auto-détection conf + binaire vendored)
    ├── phpunit-run.sh         # Lancer PHPUnit
    ├── phpunit-helix.sh       # PHPUnit pour Helix
    └── tmux-project.sh        # Sessions tmux par projet
```

## Desktop : Niri + Noctalia

Session Wayland par défaut avec :
- **Niri** — Compositeur Wayland tiling (scrollable)
- **Noctalia** — Shell desktop (barre, lockscreen, launcher, control center, notifications)

### Raccourcis Niri

| Raccourci | Action |
|-----------|--------|
| `Mod+Return` | Kitty + tmux |
| `Mod+D` | Lanceur Noctalia |
| `Mod+V` | Presse-papier (natif v5, remplace le plugin `clipper`) |
| `Mod+period` | Emoji (provider `/emo` du lanceur) |
| `Mod+M` | Control center, onglet `monitor` |
| `Mod+L` | Lockscreen Noctalia |
| `Mod+Tab` | Overview workspaces |
| `Mod+Q` | Fermer fenêtre |
| `Mod+F` | Maximiser colonne |
| `Mod+1-9` | Focus workspace |
| `Mod+Shift+1-9` | Déplacer vers workspace |
| `Mod+B` | Chrome |
| `Print` / `Mod+Shift+S` | Screenshot |

## Fichiers Nix

### `flake.nix`

Point d'entrée du système.

**Inputs :**
| Input | Description |
|-------|-------------|
| `nixpkgs` | NixOS 25.11 (stable) |
| `nixpkgs-unstable` | Paquets instables (PhpStorm, lazygit, yazi) |
| `home-manager` | Release 25.11 |
| `claude-code` | Claude Code CLI |
| `codex-cli-nix` | Codex CLI |
| `noctalia` | Noctalia shell **v5** — pinné sur le tag `v5.0.0-beta.8` (follows nixpkgs-unstable) |

**Outputs :**
- `nixosConfigurations.loicngr` — Configuration système
- `homeConfigurations.loicngr` — Configuration Home Manager

---

### `configuration.nix`

Configuration système principale NixOS.

| Section | Description |
|---------|-------------|
| Bootloader | systemd-boot, EFI |
| Réseau | NetworkManager, hostname `loicngr` |
| Locale | `fr_FR.UTF-8`, timezone `Europe/Paris` |
| Display | GDM (Wayland), session par défaut : niri |
| Desktop | GNOME (fallback), Niri (principal) |
| Audio | Pipewire |
| Bluetooth | Activé, reconnexion auto |
| Virtualisation | Docker |
| Power | Suspend/hibernation désactivés, idle ignoré |
| Utilisateur | `loicngr` (wheel, docker, kvm, adbusers, gamemode) |

**Services :**
- MySQL (MariaDB), PostgreSQL
- power-profiles-daemon, upower (prérequis Noctalia)
- GNOME Keyring, Flatpak

---

### `home-manager/niri.nix`

Configuration Wayland complète :
- **Niri** — Config KDL (layout, binds, cursor, screenshots)
- **Noctalia v5** — Shell desktop, `programs.noctalia` (settings TOML déclaratifs, plugins Luau)
- **GTK** — Catppuccin Mocha Mauve + Papirus-Dark icons
- **Curseur** — catppuccin-mocha-mauve-cursors (24px)

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

### `modules/php.nix`

Environnements PHP 8.3, 8.4 et 8.5 avec extensions complètes.

**Exports :** `myPhp83`, `myPhp84`, `myPhp85`

---

### `modules/zsh.nix`

ZSH avec Oh My ZSH.

**Alias principaux :**
| Alias | Commande |
|-------|----------|
| `nu` | Rebuild NixOS + Home Manager |
| `nup` | Update flake + rebuild |
| `nd` | Garbage collect + rebuild |
| `ts`, `tp`, `tn` | Sessions tmux projet |

**Commandes PHP :**
- `php83`, `php84`, `php85`
- `composer83`, `composer84`, `composer85`
- `use-php83`, `use-php84`, `use-php85`

Pour les IDE comme PhpStorm, `php84`, `composer84`, `php85` et `composer85` sont exposés comme vrais exécutables dans `/run/current-system/sw/bin/`.

---

### `home-manager/loicngr.nix`

Configuration utilisateur Home Manager.

**Programmes configurés :**
- **Git** — pull.rebase, merge.conflictstyle=diff3, delta (side-by-side)
- **Lazygit** — Commit Claude (`C`), Merge Claude (`M`)
- **tmux** — Prefix Ctrl+a, Catppuccin, resurrect, fzf, fingers
- **bat** — Catppuccin Mocha
- **eza** — Catppuccin, icons, git
- **fzf** — fd, Catppuccin colors, preview bat/eza
- **micro** — Dracula colorscheme

**Wrappers exposés en bin (via `writeShellScriptBin`) :**
- `eslint-wrapper`, `php-cs-fixer-wrapper`, `phpstan-wrapper`, `psalm-wrapper`
- `phpunit-run`, `claude-commit`, `claude-merge`, `tmux-project`

**Autostart (GNOME uniquement) :**
- kDrive, Element Desktop, KeePassXC, Thunderbird

---

### `home-manager/zed.nix`

Configuration de l'éditeur Zed.

| Section | Détail |
|---------|--------|
| Thème | Catppuccin Mocha (sombre) / Latte (clair) |
| Keymap | JetBrains (compat PhpStorm) |
| Extensions | catppuccin, nix, vue, twig, dockerfile, docker-compose, ruff, psalm |
| Node | `pkgs.nodejs_24` (pour les LSP qui en ont besoin) |
| Diagnostics | inline activé |
| Inlay hints | activé (params, types, valeurs en debug) |
| Brackets | colorize_brackets |

**LSP configurés :**
- **eslint** — `workingDirectory.mode = "auto"` (monorepos type `front/.eslintrc.js`)
- **psalm** — utilise `psalm-wrapper` (auto-détection conf + binaire vendored)

**PHP :**
- LSP : `phpactor` + `psalm` (parallèle)
- Formatter : `php-cs-fixer-wrapper` via stdin (avec `--stdin-filepath {buffer_path}`)
- `format_on_save` désactivé (race condition watcher Zed avec formatters lents)

**Tasks PHPStan** (palette → "task: spawn") :
- `PHPStan: analyse projet`
- `PHPStan: analyse fichier courant`

---

## Utilisation

### Reconstruction du système
```bash
# Copier vers /etc/nixos et rebuild
./copy-to-nixos.sh
sudo nixos-rebuild switch --flake /etc/nixos#loicngr
home-manager switch --flake /etc/nixos#loicngr

# Ou via alias
nu    # Rebuild seulement
nup   # Update + rebuild
```

### Synchronisation
```bash
./copy-to-nixos.sh     # Copier vers /etc/nixos
./copy-from-nixos.sh   # Copier depuis /etc/nixos
```

> **Note :** Ce dépôt est une copie des fichiers utilisés par le système (dans `/etc/nixos`).
> Avant d'appliquer une modification, il faut recopier manuellement les fichiers dans `/etc/nixos` aux bons emplacements.
