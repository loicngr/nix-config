# Commit Message Guidelines

Write a sharp and concise commit message in the conventional form of commits.
For the commit title, you must write no more than two lines (The lines must not exceed 120 characters).
No length restrictions apply to the content of the commit.
Focus particularly on the use of the GitMoji convention.
Use the present tense for the commit message.
Use French as the language to respond.

## GitMoji Reference

| Emoji | Type | Use case |
|:-----:|:----:|:---------|
| ✨ | feat | New feature |
| 🔖 | chore | Release / Version tags |
| 🚧 | feat | Work in progress |
| 🧱 | feat | Infrastructure changes |
| 🏰 | feat | Launch plan changes |
| 🔱 | feat | Permissions in infrastructure |
| 🏗️ | refactor | Architectural changes |
| 🌱 | feat | Add seeds |
| 💚 | chore | CI |
| 👷 | chore | New CI build |
| ⬇️ | refactor | Downgrade dependencies |
| ⬆️ | refactor | Upgrade dependencies |
| 📌 | feat | Pin dependency version |
| ➕ | refactor | New dependency |
| ➖ | refactor | Remove dependency |
| 📦️ | chore | New packages |
| ♻️ | refactor | Code refactoring |
| 🎨 | style | Improve code structure/format |
| 🚚 | refactor | Move/rename files |
| 🍱 | feat | Add assets |
| 🔥 | refactor | Delete code/files |
| 🚨 | style | Fix linter warnings |
| ✏️ | fix | Fix typos |
| ⚰️ | chore | Remove dead code |
| 🐋 | chore | Docker related |
| 🗃 | - | Database related |
| 🐛 | fix | Bug fixes |
| 🚑️ | fix | Critical Hot-Fix |
| 💥 | feat | Breaking changes |
| 🩹 | - | Non-critical fix |
| 🙈 | feat | gitignore |
| ✋ | feat | Alternative implementation |
| 🔇 | docs | Remove logs |
| 🔊 | docs | Add logs |
| 💬 | feat | Update literals/text |
| 📝 | docs | Documentation |
| 🦺 | - | Model/DB validations |
| 🩺 | - | Healthcheck |
| 🧪 | - | Failing tests |
| ✅ | test | Passing tests |
| ⚗️ | feat | Experiments |
| ⚡️ | feat | Performance |
| 🚀 | chore | Deployment |
| 💄 | feat | UI related |
| 🚸 | feat | UX related |
| 🌐 | feat | i18n/l10n |
| 📱 | refactor | Responsive/mobile |
| 👮 | chore | Security additions |
| 🔒️ | fix | Security issues |
| 🔐 | - | Secrets/keys |
| 🌳 | - | .env files |
| 🔧 | feat | Config files |
| 💩 | refactor | FIXME/bad code |
| 🍻 | feat | Drunk coding |
| 🥚 | refactor | Easter Egg |

**NEVER use emoji text like ":sparkles:", ALWAYS use graphic version like "✨"**

**IMPORTANT: Output ONLY the raw commit message text. NEVER wrap it in backticks (```), quotes, or any markdown formatting.**

**IMPORTANT: Ne pose AUCUNE question. Tu ne recevras pas de réponse. Génère directement le message de commit à partir du diff fourni.**

## Expected Structure

```
[EMOJI] [$GIT_BRANCH_NAME] - [TYPE]([SCOPE]): [DESCRIPTION IN FRENCH]

 - [EMOJI] [TYPE]([SCOPE]): [DETAIL IN FRENCH]
 - ...
```

**IMPORTANT: The GIT BRANCH NAME is REQUIRED in all commit messages.**

If only a title is needed, do not generate additional lines.

## Example

```
✨ feature/TK562-onboarding - feat(onboarding): Amélioration de l'interface et des fonctionnalités de gestion des parcours d'onboarding

 - ♻️ refactor(routes): Suppression de la structure de routes enfants pour les tutoriels
 - ✨ feat(UI): Ajout d'un bouton pour créer de nouveaux parcours d'onboarding
 - ✨ feat(UI): Implémentation des actions en masse pour activer/désactiver plusieurs parcours
 - ✨ feat(filtres): Ajout du filtre par statut pour les parcours d'onboarding
 - ♻️ refactor(modal): Amélioration du comportement des modales
 - ✨ feat(API): Mise à jour du repository pour supporter les nouveaux filtres
```
