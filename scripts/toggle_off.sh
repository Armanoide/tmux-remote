#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/variables.sh"

tmux set -g status on
tmux set -u prefix
tmux set -u key-table

# @remote-one-bar "on" → restore the child's bar via the child-show key sent into
# the ssh pane.
one_bar="$(tmux show-options -gv "$one_bar_option" 2>/dev/null)"
if [[ "$one_bar" == "on" ]]; then
    child_show_key="$(tmux show-options -gv "$child_show_key_option" 2>/dev/null)"
    # Target format MUST be window.pane (e.g. "4.1"), NOT %pane_id: on nested ssh
    # the key only traverses to the child with window.pane addressing (verified real).
    remote_pane="$(tmux list-panes -a -F '#{window_index}.#{pane_index} #{pane_current_command}' | awk '$2=="ssh"{print $1; exit}')"
    [[ -n "$remote_pane" ]] && tmux send-keys -t "$remote_pane" "$child_show_key"
fi

# Restore the original status-left saved by toggle_on, then clear the saved value so
# the next toggle_on cycle saves the current status-left rather than the stale snapshot.
saved="$(tmux show-option -gv "$saved_status_left_option" 2>/dev/null)"
if [[ -n "$saved" ]]; then
    tmux set -g status-left "$saved"
fi
tmux set -gu "$saved_status_left_option"

tmux refresh-client -S
