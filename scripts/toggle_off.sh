#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/variables.sh"

tmux set -g status on
tmux set -u prefix
tmux set -u key-table

# @remote-one-bar "on" → exactly one bar visible. The parent shows its own bar
# below, so the nested child must HIDE its bar (inverse rule). The hide key is
# sent into the focused pane as window.pane "W.P" — %pane_id does not traverse
# nested ssh (verified real). Default "off" = upstream behavior (badge only).
one_bar="$(tmux show-options -gv "$one_bar_option" 2>/dev/null)"
if [[ "$one_bar" == "on" ]]; then
    child_hide_key="$(tmux show-options -gv "$child_hide_key_option" 2>/dev/null)"
    remote_pane="$(tmux display-message -p '#{window_index}.#{pane_index}')"
    [[ -n "$remote_pane" ]] && tmux send-keys -t "$remote_pane" "$child_hide_key"
fi

# Restore the original status-left saved by toggle_on, then clear the saved value so
# the next toggle_on cycle saves the current status-left rather than the stale snapshot.
saved="$(tmux show-option -gv "$saved_status_left_option" 2>/dev/null)"
if [[ -n "$saved" ]]; then
    tmux set -g status-left "$saved"
fi
tmux set -gu "$saved_status_left_option"

# @remote-one-bar "on" → the parent's restored bar carries the LOCAL badge
# (the child's bar is hidden above, showing REMOTE when it comes back).
if [[ "$one_bar" == "on" ]]; then
    text="$(tmux show-option -gv "$local_indicator_text_option")"
    fg="$(tmux show-option -gv "$local_indicator_fg_option")"
    bg="$(tmux show-option -gv "$local_indicator_bg_option")"
    tmux set -g status-left "#[fg=$fg,bg=$bg]$text#[bg=default] "
fi

tmux refresh-client -S
