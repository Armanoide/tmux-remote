#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/variables.sh"

# Save the current status-left so toggle_off can restore it (only once)
saved="$(tmux show-option -gv "$saved_status_left_option" 2>/dev/null)"
if [[ -z "$saved" ]]; then
    tmux set -g "$saved_status_left_option" "$(tmux show-option -gv status-left)"
fi

# Read indicator options
text="$(tmux show-option -gv "$indicator_text_option")"
fg="$(tmux show-option -gv "$indicator_fg_option")"
bg="$(tmux show-option -gv "$indicator_bg_option")"

# @remote-one-bar "on" → exactly one bar visible: send the child-hide key into
# the ssh pane so the nested child hides its own bar. Default "off" = upstream.
one_bar="$(tmux show-options -gv "$one_bar_option" 2>/dev/null)"
if [[ "$one_bar" == "on" ]]; then
    child_hide_key="$(tmux show-options -gv "$child_hide_key_option" 2>/dev/null)"
    # Target format MUST be window.pane (e.g. "4.1"), NOT %pane_id: on nested ssh
    # the key only traverses to the child with window.pane addressing (verified real).
    remote_pane="$(tmux list-panes -a -F '#{window_index}.#{pane_index} #{pane_current_command}' | awk '$2=="ssh"{print $1; exit}')"
    [[ -n "$remote_pane" ]] && tmux send-keys -t "$remote_pane" "$child_hide_key"
fi

tmux set -g status off
tmux set prefix None
tmux set key-table off
tmux set -g status-left "#[fg=$fg,bg=$bg]$text#[bg=default] "
tmux if -F '#{pane_in_mode}' 'send-keys -X cancel'
tmux refresh-client -S
