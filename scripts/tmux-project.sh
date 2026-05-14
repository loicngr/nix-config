#!/usr/bin/env bash
# Usage: tmux-project <project-name>
# Crée toujours une nouvelle session tmux (sekur, sekur-2, sekur-3, ...).

PROJECT="$1"

case "$PROJECT" in
  sekur)
    DIR="$HOME/PhpstormProjects/sekur"
    LAYOUT="quad"
    ;;
  propret)
    DIR="$HOME/PhpstormProjects/propret"
    LAYOUT="quad"
    ;;
  nixos)
    DIR="$HOME/PhpstormProjects/nix-config"
    LAYOUT="split"
    ;;
  *)
    echo "Projet inconnu: $PROJECT"
    echo "Projets disponibles: sekur, propret, nixos"
    exit 1
    ;;
esac

# Nom unique : sekur, sekur-2, sekur-3, ...
SESSION="$PROJECT"
N=2
while tmux has-session -t "$SESSION" 2>/dev/null; do
  SESSION="${PROJECT}-${N}"
  N=$((N + 1))
done

# attach ou switch selon qu'on est déjà dans tmux
connect() {
  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$SESSION"
  else
    tmux attach-session -t "$SESSION"
  fi
}

if [ "$LAYOUT" = "quad" ]; then
  # 2x2 grid
  tmux new-session -d -s "$SESSION" -c "$DIR"
  tmux split-window -h -t "$SESSION" -c "$DIR"
  tmux select-pane -t "$SESSION":0.0
  tmux split-window -v -t "$SESSION" -c "$DIR"
  tmux select-pane -t "$SESSION":0.2
  tmux split-window -v -t "$SESSION" -c "$DIR"
  tmux select-pane -t "$SESSION":0.0
  connect
elif [ "$LAYOUT" = "split" ]; then
  # 2 panes côte à côte
  tmux new-session -d -s "$SESSION" -c "$DIR"
  tmux split-window -h -t "$SESSION" -c "$DIR"
  tmux select-pane -t "$SESSION":0.0
  connect
fi
