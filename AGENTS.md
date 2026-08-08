## Informations pour les agents IA

Ce dépôt est une copie des fichiers utilisés par le système (dans `/etc/nixos`).
Avant d'appliquer une modification, il faut recopier manuellement les fichiers
dans `/etc/nixos` aux bons emplacements.

## Prise de connaissance obligatoire

Avant toute proposition technique ou modification de fichier, l'agent IA DOIT
prendre connaissance des éléments de configuration NixOS du dépôt.

### Fichiers à lire systématiquement

- `flake.nix` (inputs/outputs, modules importés, `specialArgs`)
- `configuration.nix` (configuration système principale)
- `modules/*.nix` (modules système et shells)
- `home-manager/*.nix` (configuration utilisateur)
- `copy-to-nixos.sh` et `copy-from-nixos.sh` (règles de synchronisation)
- `README.md` (structure et conventions du dépôt)

### Vérifications minimales obligatoires

- Identifier le point d'entrée concerné par la demande (`flake.nix`,
  `configuration.nix`, `modules/` ou `home-manager/`).
- Vérifier les imports et les arguments passés aux modules pour éviter les
  références cassées.
- Vérifier si les fichiers impactés sont bien synchronisés par les scripts
  `copy-to-nixos.sh` et `copy-from-nixos.sh`.
- Dans la réponse, mentionner explicitement les fichiers consultés.

### Interdiction

Ne pas modifier la configuration NixOS "à l'aveugle". Toute modification sans
lecture préalable des fichiers ci-dessus est considérée comme invalide.

### Scripts de synchronisation

- `./copy-to-nixos.sh` : copie les fichiers vers `/etc/nixos`
- `./copy-from-nixos.sh` : copie les fichiers depuis `/etc/nixos`

**Important :** Si tu ajoutes un nouveau fichier ou répertoire qui doit être synchronisé, pense à mettre à jour les deux scripts `copy-to-nixos.sh` et `copy-from-nixos.sh`.

### Politique de mise à jour NixOS

- L'agent IA NE DOIT JAMAIS lancer une mise à jour NixOS.
- Les commandes de type `nix flake update`, `nixos-rebuild --upgrade`, `nup` (ou équivalent) sont réservées à l'humain.
- L'agent peut proposer des changements de configuration et lancer des builds/switch, mais la décision d'update reste strictement humaine.

### Noctalia (v5)

**Migré en v5 le 2026-08-06** (`v5.0.0-beta.7`). Binaire : `noctalia`. IPC : `noctalia msg <cmd>`.
Module Home Manager : `programs.noctalia` (config **TOML**), dans `home-manager/niri.nix`.

#### Récupérer les réglages faits via l'interface

L'UI écrit dans `~/.local/state/noctalia/settings.toml`, une couche chargée **après**
le fichier déclaratif et qui **gagne** sur lui. Workflow pour rendre un réglage permanent :

1. `noctalia config export full > /tmp/before.toml` (config fusionnée, référence)
2. Traduire `~/.local/state/noctalia/settings.toml` (= uniquement les modifs UI) en
   attrset Nix dans `programs.noctalia.settings`, puis `home-manager build`
3. Appliquer, **supprimer `~/.local/state/noctalia/settings.toml`** (ce fichier UNIQUEMENT —
   le reste du répertoire contient les plugins matérialisés, l'historique du presse-papier…)
4. Vérifier : `noctalia config export full` doit être **identique** à `/tmp/before.toml`

#### Points de vigilance

- **`noctalia config validate` n'est PAS un garde-fou.** Les clés inconnues et les valeurs
  d'énumération invalides ne sortent qu'en *warning*, en **code 0** ; les IDs de widgets de barre
  ne sont **pas validés du tout**. Un build vert ne prouve rien : une typo donne un widget
  silencieusement absent. Contrôler au runtime :
  `journalctl --user -b | grep 'unknown widget'`.
- **Démarrage** : `spawn-at-startup "noctalia"` dans la config niri (méthode recommandée par la
  doc v5). Ne PAS activer `programs.noctalia.systemd.enable` — jamais deux mécanismes à la fois.
- **Arrêter le shell** : `pkill -x noctalia` ne marche pas (le process est `.noctalia-wrapped`).
  Utiliser `pkill -f 'bin/noctalia$'`.
- **`[idle]`** : les 3 comportements built-in de v5 sont `enabled = false`, et déclarer un seul
  `[idle.behavior.*]` **remplace toute** la liste (pas de fusion). Sans déclaration, la machine ne
  se verrouille plus jamais seule.
- **Authentification du lockscreen** : service PAM `login`, qu'aucun module Nix upstream ne
  configure. Après toute modification touchant au verrouillage, tester `Mod+L` avec un TTY de
  secours ouvert (`Ctrl+Alt+F2` → `loginctl unlock-session`).
- **Ne jamais activer les templates de thème** (`kitty`, `niri`, `gtk`, `qt`…) : ces chemins sont
  des symlinks Home Manager en lecture seule → échec, ou fichier réel qui casse les rebuilds.
- L'input flake est pinné sur le **tag** `v5.0.0-beta.7` : `nup` ne re-bumpe donc pas le shell,
  la montée de version est une modification explicite de `flake.nix`. Rollback = branche `main`
  (v4.7.7 sur `legacy-v4`) ; la conf v4 est archivée dans `config/noctalia/v4-archive/`.
- En cas d'erreur Home Manager « would be clobbered » sur des fichiers Noctalia : supprimer les
  `~/.config/noctalia/*.backup` puis relancer. Arrêter le shell **avant** un switch qui change
  ses fichiers de config évite le problème.
- Pré-requis NixOS pour les fonctionnalités Noctalia (wifi/bluetooth/power/battery) :
  `networking.networkmanager.enable`, `hardware.bluetooth.enable`,
  `services.power-profiles-daemon.enable` (ou `services.tuned.enable`), `services.upower.enable`.
