# Configuration NixOS de loicngr

Configuration personnelle d’une station de développement web et mobile, avec Niri,
Noctalia, un GPU hybride Intel/NVIDIA et un environnement utilisateur géré par
Home Manager.

Ce dépôt est la copie de travail de la configuration déployée dans `/etc/nixos`.
Modifier un fichier ici ne change pas le système actif : il faut le synchroniser,
puis reconstruire la configuration concernée.

## Configuration déclarée

| Élément | Configuration |
| --- | --- |
| Architecture | `x86_64-linux` |
| Machine et utilisateur | `loicngr` |
| NixOS / Home Manager | Branches `nixos-26.05` / `release-26.05` |
| Paquets complémentaires | `nixos-unstable` |
| Noctalia | Tag `v5.5.0` |
| Explorateur de fichiers | Luciole `0.1.0`, révision `8385675` |
| Session graphique | Niri, lancée depuis GDM |
| Langue et fuseau horaire | `fr_FR.UTF-8`, `Europe/Paris` |
| Terminal et shell | Kitty, Zsh, tmux |
| GPU | Intel/NVIDIA PRIME offload, pilote NVIDIA ouvert |
| Audio | PipeWire |

Les révisions exactes des dépendances sont enregistrées dans `flake.lock`.
Les valeurs `system.stateVersion` et `home.stateVersion` restent à `25.11` : elles
ne désignent pas la version courante des paquets.

## Organisation du dépôt

| Chemin | Rôle |
| --- | --- |
| `flake.nix` | Dépendances, overlays et points d’entrée NixOS/Home Manager |
| `flake.lock` | Révisions verrouillées des dépendances |
| `configuration.nix` | Services, utilisateur, paquets et configuration système |
| `modules/nvidia.nix` | Pilote NVIDIA, PRIME offload et prise en charge graphique |
| `modules/php.nix` | Environnements PHP 8.3, 8.4 et 8.5 |
| `modules/zsh.nix` | Zsh, alias système et commandes PHP |
| `home-manager/loicngr.nix` | Paquets et outils utilisateur, Git, tmux et services utilisateur |
| `home-manager/niri.nix` | Niri, Noctalia, GTK, curseur et notifications sonores |
| `home-manager/kitty.nix` | Terminal Kitty |
| `home-manager/luciole.nix` | Luciole, association des dossiers et service D-Bus |
| `home-manager/helix.nix`, `home-manager/nvchad.nix` | Configurations présentes mais non importées |
| `scripts/` | Wrappers de développement et commandes Git/tmux |
| `config/` | Configurations Lazygit/lazyworktree et archives Noctalia v4 |
| `images/`, `sounds/` | Ressources utilisées par la configuration |
| `copy-to-nixos.sh`, `copy-from-nixos.sh` | Copie entre le dépôt et `/etc/nixos` |
| `AGENTS.md` | Instructions destinées aux assistants IA |

`hardware-configuration.nix` est importé par la configuration système, mais reste
propre à la machine dans `/etc/nixos`. Il n’est ni versionné ici, ni copié par les
scripts. Une reconstruction NixOS directement depuis ce dépôt nécessite donc ce
fichier supplémentaire.

Le flake expose deux configurations indépendantes :

- `nixosConfigurations.loicngr` : le système, avec `unstable` et `luciole` passés aux modules.
- `homeConfigurations.loicngr` : Home Manager, avec `unstable`, `noctalia` et les
  environnements PHP fournis par `modules/php.nix`.

Home Manager importe les modules Noctalia et Luciole ainsi que `loicngr.nix`, qui
importe à son tour `kitty.nix`, `luciole.nix` et `niri.nix`. Les overlays Claude Code et Codex sont appliqués
aux paquets Home Manager. Solaar utilise un overlay vers unstable pour contourner
un problème de build de la version stable.

## Synchroniser et appliquer

Exécuter les scripts depuis la racine du dépôt : ils utilisent le répertoire
courant comme source ou destination.

```bash
# Copier la configuration du dépôt vers la machine
./copy-to-nixos.sh

# Construire sans activer
sudo nixos-rebuild build --flake /etc/nixos#loicngr
home-manager build --flake /etc/nixos#loicngr

# Appliquer le système et l’environnement utilisateur
sudo nixos-rebuild switch --flake /etc/nixos#loicngr
home-manager switch --flake /etc/nixos#loicngr
```

Pour récupérer des modifications réalisées dans `/etc/nixos` :

```bash
./copy-from-nixos.sh
git diff
```

Les scripts copient `configuration.nix`, `flake.nix`, `flake.lock`, ainsi que les
répertoires `modules`, `home-manager`, `images`, `sounds`, `scripts` et `config`.
Ils écrasent les fichiers de même nom, mais ne suppriment pas les fichiers devenus
obsolètes à destination. Le README et les instructions des agents ne sont pas
synchronisés.

Tout nouveau fichier placé hors de ces répertoires et nécessaire au déploiement
doit être ajouté aux deux scripts.

### Alias de maintenance

| Alias | Action |
| --- | --- |
| `nu` | Applique NixOS puis Home Manager depuis `/etc/nixos`, via `nh` |
| `nup` | Met à jour le verrouillage du flake dans `/etc/nixos`, puis applique les deux configurations |
| `nd` | Supprime les générations visées par `nix-collect-garbage --delete-older-than 30d`, puis lance `nu` |
| `ncg` | Lance `nh clean all --ask` |

Ces alias ne recopient pas le dépôt. **Les mises à jour, dont `nup` et
`nix flake update`, sont réservées à l’humain.** Un agent ne doit jamais les lancer.
Après une mise à jour dans `/etc/nixos`, récupérer notamment `flake.lock` dans le
dépôt pour conserver les révisions utilisées.

La mise à jour automatique du système et le nettoyage automatique de `nh` sont
désactivés. L’optimisation automatique du store est activée ; elle ne remplace pas
le nettoyage des chemins inutilisés. Les anciennes générations peuvent conserver
des paquets retirés de la configuration et permettre un retour arrière.

## Bureau Niri et composants GNOME

La session GNOME complète est désactivée. GDM reste l’écran de connexion et Niri
la session par défaut. Certains composants GNOME restent nécessaires à GDM ou
aux portails de Niri.

Les éléments conservés explicitement comprennent :

- GNOME Keyring, agent SSH GCR et Seahorse pour les secrets et les clés ;
- Evolution Data Server et GNOME Online Accounts pour les calendriers et comptes ;
- GVfs et UDisks2 pour les fichiers et volumes, Avahi pour la découverte réseau ;
- portails GTK/GNOME pour les fonctions complémentaires et le partage d’écran ;
- DConf, Polkit, AT-SPI et Orca ;
- Horloges et Loupe, utilisée par défaut pour les images.

Steam n’est plus activé, GameMode est désactivé et le support graphique 32 bits
est désactivé dans `modules/nvidia.nix`. Le pilote NVIDIA 64 bits et PRIME offload
restent disponibles.

La suspension et l’hibernation sont désactivées au niveau système. Noctalia gère
séparément l’extinction des écrans après 600 secondes et le verrouillage après
660 secondes d’inactivité.

### Raccourcis principaux

`Mod` correspond à la touche Super.

| Raccourci | Action |
| --- | --- |
| `Mod+Return` | Kitty avec une nouvelle session tmux |
| `Mod+Shift+Return` | Kitty |
| `Mod+D` | Lanceur Noctalia |
| `Mod+E` | Explorateur Luciole |
| `Mod+V` | Presse-papier Noctalia |
| `Mod+period` | Recherche d’emoji |
| `Mod+M` | Centre de contrôle, onglet moniteur |
| `Mod+L` | Verrouillage |
| `Mod+Tab` | Vue d’ensemble |
| `Mod+Q` | Fermer la fenêtre |
| `Mod+F` / `Mod+Shift+F` | Maximiser la colonne / plein écran |
| `Mod+Space` | Basculer la fenêtre en mode flottant |
| `Mod+1…9` / `Mod+Shift+1…9` | Changer d’espace / déplacer la colonne |
| `Mod+B` / `Mod+Shift+B` | Chrome / Chrome WebGPU avec profil séparé |
| `Print` ou `Mod+Shift+S` | Capture d’une région |
| `Mod+Print` | Capture plein écran |

Les équivalents AZERTY des touches numériques sont également déclarés dans
`home-manager/niri.nix`.

### Explorateur Luciole

Luciole remplace Nautilus pour ouvrir les dossiers et les dialogues de sélection
de fichiers. L’association `inode/directory`, l’alias Zsh `open` et le service
D-Bus `org.freedesktop.FileManager1` pointent vers Luciole. L’intégration automatique
de Nautilus dans le module Niri est désactivée.

Home Manager gère `~/.config/niri-mimeapps.list` pour les dossiers et les PDF
(ouverts dans Chrome), sans écraser le fichier personnel `mimeapps.list` ni ses
autres associations.

Le portail de sélection utilise `luciole`, puis `gtk` si le premier backend est
absent. Ce repli ne couvre pas un backend présent qui échoue. Le portail GNOME
reste installé pour le partage d’écran.

Le paquet upstream fournit les outils pour les miniatures vidéo/PDF et les
archives. Le terminal est Kitty et le cache des miniatures créées par Luciole est
limité à 256 Mio. Les réglages déclaratifs sont dans `~/.config/luciole/config.toml` ;
les changements de l’interface sont conservés séparément dans `settings.toml` et
prennent priorité. Les favoris GTK existants sont réutilisés.

Luciole est encore en développement. Les emplacements distants nécessitent les
services GVfs correspondants et une connexion déjà authentifiée ; ses propres
dialogues de connexion réseau ne sont pas encore implémentés. La révision du flake
est fixée explicitement, comme celle de Noctalia.

Après la première activation NixOS et Home Manager, rouvrir la session pour que
les portails et D-Bus utilisent les nouveaux fournisseurs. Vérifier ensuite :

```bash
xdg-mime query default inode/directory  # dev.noctalia.luciole.desktop
luciole config validate ~/.config/luciole/config.toml
```

Documentation : [Luciole](https://docs.noctalia.dev/luciole/).

### Réglages Noctalia

Noctalia est lancé par `spawn-at-startup "noctalia"` dans Niri. Ne pas activer en
parallèle son démarrage par un service systemd Home Manager.

Les réglages déclaratifs sont dans `programs.noctalia.settings` et produisent du
TOML. Les modifications réalisées dans l’interface sont stockées dans
`~/.local/state/noctalia/settings.toml` et prennent priorité sur le déclaratif.

Pour intégrer ces modifications au dépôt :

1. Exporter la configuration fusionnée avec
   `noctalia config export full > /tmp/noctalia-before.toml`.
2. Reporter les réglages de la couche utilisateur dans `home-manager/niri.nix`.
3. Synchroniser, construire et appliquer Home Manager.
4. Supprimer uniquement le fichier de surcharge `settings.toml`, puis comparer
   un nouvel export complet à la référence.

Ne pas supprimer le reste du répertoire d’état : il contient notamment les
plugins et l’historique du presse-papier. Les templates de thème restent désactivés
pour éviter de réécrire les liens en lecture seule gérés par Home Manager.

Un build réussi ne valide pas les identifiants des widgets. Après une modification,
contrôler l’interface et les éventuels messages `unknown widget` dans le journal
utilisateur. Pour un changement de verrouillage, tester `Mod+L` avec un TTY de
secours ouvert. Les instructions détaillées sont dans `AGENTS.md` ; les versions
effectivement déclarées sont celles de `flake.nix` et `flake.lock`.

## Environnement de développement

### PHP

`modules/php.nix` fournit PHP 8.3, 8.4 et 8.5 avec Composer, PHP-CS-Fixer et les
extensions de développement, dont Xdebug. PHP 8.3 est l’interpréteur système par
défaut ; Xdebug utilise le mode `develop` et la limite mémoire PHP est de 2 Gio.

- `php83`, `php84`, `php85` et `composer83`, `composer84`, `composer85` : alias Zsh.
- `use-php83`, `use-php84`, `use-php85` : sélection dans le shell courant.
- `php84`, `php85`, `composer84`, `composer85` : également disponibles comme vrais
  exécutables dans `/run/current-system/sw/bin/`, notamment pour les IDE.

### Autres outils

La configuration comprend notamment PhpStorm, Android Studio, Java 17/21,
Gradle, Kotlin, Rust, Python, Bun, uv, Docker et les outils Kubernetes.
Node.js est géré avec `fnm`, initialisé par Zsh. MariaDB 11.4 et PostgreSQL 18
sont activés comme services locaux.

`appimage-run` et l’intégration AppImage sont conservés pour les applications
externes, dont kDrive. `nix-ld` fournit les bibliothèques utilisées par les binaires
non empaquetés pour NixOS, notamment Cypress téléchargé via Node. Cette liste ne
doit pas être réduite sans tester ces usages.

Les wrappers de `scripts/` sont exposés par Home Manager : ESLint,
PHP-CS-Fixer, PHPStan, Psalm, PHPUnit, commits et merges assistés par Claude,
ainsi que les sessions tmux par projet. `phpunit-helix.sh` est présent, mais n’est
pas exposé par la configuration Home Manager active.

Lazygit utilise `C` pour générer un message de commit et `M` pour lancer le workflow
de merge assisté. Le préfixe tmux est `Ctrl+a` ; `ts`, `tsa`, `tp` et `tn` ouvrent
les sessions de projets définies dans `modules/zsh.nix`.

## Données propres à la machine

Le dépôt ne contient pas toutes les données nécessaires aux applications :

- `hardware-configuration.nix` reste dans `/etc/nixos` ;
- le fond d’écran Noctalia référence un fichier de `~/Pictures` ;
- kDrive est attendu dans `~/Apps/kDrive.AppImage` ;
- les identifiants des comptes et le contenu du keyring restent dans le profil utilisateur ;
- le montage utilisateur `rclone-webdav-lwf` dépend de
  `~/.config/rclone/rclone.conf` et monte le distant `lwf-webdav:` dans `~/webdav-lwf`.

Les fichiers d’autostart de kDrive, Element, KeePassXC et Thunderbird sont déclarés
par Home Manager dans `~/.config/autostart`.
