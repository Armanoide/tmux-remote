#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/variables.sh"
source "$CURRENT_DIR/scripts/helpers.sh"

main() {
	if option_not_set "$toggle_key_option"; then
		tmux set-option -g "$toggle_key_option" "$default_toggle_key"
	fi
	if option_not_set "$on_key_option"; then
		tmux set-option -g "$on_key_option" "$default_on_key"
	fi
	if option_not_set "$off_key_option"; then
		tmux set-option -g "$off_key_option" "$default_off_key"
	fi
	if option_not_set "$indicator_text_option"; then
		tmux set-option -g "$indicator_text_option" "$default_indicator_text"
	fi
	if option_not_set "$indicator_fg_option"; then
		tmux set-option -g "$indicator_fg_option" "$default_indicator_fg"
	fi
	if option_not_set "$indicator_bg_option"; then
		tmux set-option -g "$indicator_bg_option" "$default_indicator_bg"
	fi
	if option_not_set "$one_bar_option"; then
		tmux set-option -g "$one_bar_option" "off"
	fi
	if option_not_set "$child_hide_key_option"; then
		tmux set-option -g "$child_hide_key_option" "$default_child_hide_key"
	fi
	if option_not_set "$child_show_key_option"; then
		tmux set-option -g "$child_show_key_option" "$default_child_show_key"
	fi

	local toggle_key; toggle_key=$(tmux show-option -gv "$toggle_key_option")
	local on_key; on_key=$(tmux show-option -gv "$on_key_option")
	local off_key; off_key=$(tmux show-option -gv "$off_key_option")

	tmux unbind -T root "$toggle_key" 2>/dev/null || true
	tmux unbind -T off "$toggle_key" 2>/dev/null || true
	tmux unbind -T root "$on_key" 2>/dev/null || true
	tmux unbind -T off "$on_key" 2>/dev/null || true
	tmux unbind -T root "$off_key" 2>/dev/null || true
	tmux unbind -T off "$off_key" 2>/dev/null || true

	# Press the toggle key to toggle "remote mode"; disables host bindings for
	# using tmux in nested sessions
	tmux bind -T root "$toggle_key" \
		run-shell "$CURRENT_DIR/scripts/toggle_on.sh"
	tmux bind -T off "$toggle_key" \
		run-shell "$CURRENT_DIR/scripts/toggle_off.sh"

	tmux bind -T root "$on_key" \
		run-shell "$CURRENT_DIR/scripts/toggle_on.sh"
	tmux bind -T off "$on_key" \
		run-shell "$CURRENT_DIR/scripts/toggle_on.sh"

	tmux bind -T root "$off_key" \
		run-shell "$CURRENT_DIR/scripts/toggle_off.sh"
	tmux bind -T off "$off_key" \
		run-shell "$CURRENT_DIR/scripts/toggle_off.sh"

	# @remote-one-bar "on" → install child-side bindings so the parent can
	# hide/restore this server's bar via send-keys into the ssh pane. Default "off"
	# = upstream behavior (badge only, no child bar control).
	local one_bar; one_bar="$(tmux show-option -gv "$one_bar_option")"
	if [[ "$one_bar" == "on" ]]; then
		local child_hide_key; child_hide_key=$(tmux show-option -gv "$child_hide_key_option")
		local child_show_key; child_show_key=$(tmux show-option -gv "$child_show_key_option")
		tmux bind-key -n "$child_hide_key" "set -g status off"
		tmux bind-key -n "$child_show_key" "set -g status on"
	fi
}

main
