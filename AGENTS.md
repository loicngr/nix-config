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

### Noctalia

Comme `~/.config/noctalia/settings.json` est désormais un symlink en lecture seule, tu peux récupérer les derniers réglages (ou ceux modifiés via l'interface) via :
- `Open Settings Panel -> General -> Copy Settings`
- `noctalia-shell ipc call state all | jq .settings`

Ensuite, utilise ces réglages pour mettre à jour la config Nix afin d'obtenir un changement permanent.

- Pré-requis NixOS à vérifier pour les fonctionnalités Noctalia (wifi/bluetooth/power/battery) :
  `networking.networkmanager.enable`, `hardware.bluetooth.enable`,
  `services.power-profiles-daemon.enable` (ou `services.tuned.enable`), `services.upower.enable`.
- Si Noctalia est configuré via Home Manager, préférer `programs.noctalia-shell.systemd.enable = true` côté Home Manager.
- Ne jamais activer le service systemd Noctalia à la fois dans le module NixOS et dans Home Manager (collision possible, comportement imprévisible).
- En cas d'erreur Home Manager liée aux backups Noctalia (`colors.json.backup`/`settings.json.backup` “would be clobbered”), supprimer ou déplacer ces fichiers puis relancer le rebuild.
- Les wallpapers Noctalia sont gérés via `~/.cache/noctalia/wallpapers.json` si besoin d'une gestion déclarative.
