#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/variables.sh"

# Save the current status-left so toggle_off can restore it (only once)
saved="$(tmux show-option -gv "$saved_status_left_option" 2>/dev/null)"
if [[ -z "$saved" ]]; then
    tmux set -g "$saved_status_left_option" "$(tmux show-option -gv status-left)"
fi

# @remote-one-bar "on" → exactly one bar visible. The parent hides its own bar
# below, so the nested child must SHOW its bar (inverse rule). The show key is
# sent into the focused pane as window.pane "W.P" — %pane_id does not traverse
# nested ssh (verified real). Default "off" = upstream behavior (badge only).
one_bar="$(tmux show-options -gv "$one_bar_option" 2>/dev/null)"
if [[ "$one_bar" == "on" ]]; then
    child_show_key="$(tmux show-options -gv "$child_show_key_option" 2>/dev/null)"
    remote_pane="$(tmux display-message -p '#{window_index}.#{pane_index}')"
    [[ -n "$remote_pane" ]] && tmux send-keys -t "$remote_pane" "$child_show_key"
fi

# Badge: written to the dedicated @remote-status slot, never to status-left
# directly — themes (catppuccin, …) keep ownership of status-left. The user's
# .tmux.conf declares: set -g status-left "#{E:@remote_status}" after the theme.
# With @remote-one-bar "on" the parent's badge is LOCAL (child shows REMOTE);
# with "off" = upstream badge text.
text="$(tmux show-option -gv "$indicator_text_option")"
fg="$(tmux show-option -gv "$indicator_fg_option")"
bg="$(tmux show-option -gv "$indicator_bg_option")"
if [[ "$one_bar" == "on" ]]; then
	text="$(tmux show-option -gv "$local_indicator_text_option")"
	fg="$(tmux show-option -gv "$local_indicator_fg_option")"
	bg="$(tmux show-option -gv "$local_indicator_bg_option")"
fi

tmux set -g status off
tmux set prefix None
tmux set key-table off
if [[ "$one_bar" == "on" ]]; then
	tmux set -g "$remote_status_option" "#[bg=default,fg=$bg] #[bg=$bg,fg=$fg]$text#[bg=default,fg=$bg] "
fi
tmux if -F '#{pane_in_mode}' 'send-keys -X cancel'
tmux refresh-client -S
