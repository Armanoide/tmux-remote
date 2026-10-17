# tmux-remote (fork Armanoide)

`tmux-remote` is a simple plugin that allows for toggling your tmux session's keybindings. This is especially useful when in nested remote tmux sessions that use the same prefix key as the host.

Tested and working on macOS and Linux. Requires tmux 2.1+.

This fork adds **one-bar mode** (`@remote-one-bar`): in nested sessions (parent → ssh → child tmux), exactly ONE status bar is visible at a time — always the one of the server that has keyboard focus — with `LOCAL` / `REMOTE` badges that never overwrite your theme's `status-left`.

## Installation

#### Install with TPM
Install using [tpm](https://github.com/tmux-plugins/tpm) (tmux Plugin Manager)

By adding the following in your `.tmux.conf`:

```tmux
set -g @plugin 'Armanoide/tmux-remote'
```

Then hit `prefix + I` to fetch the plugin and source it.

#### Manual Install

Clone the repo:

    $ git clone https://github.com/Armanoide/tmux-remote

Add this line to the bottom of `.tmux.conf`:

```tmux
run-shell ~/path/to/tmux-remote/remote.tmux
```

Then reload your tmux environment with `$ tmux source-file ~/.tmux.conf`.

## Usage

After installing the plugin, simply press <kbd>F12</kbd> to toggle remote-mode on and off.

| Key             | Action                  |
| --------------  | ----------------------- |
| <kbd>F10</kbd>  | Turns on remote mode    |
| <kbd>F11</kbd>  | Turns off remote mode   |
| <kbd>F12</kbd>  | Toggles the remote mode |

### Options

#### Keybindings

```tmux
# Change the default on keybinding (F10)
set -g @remote-on-key F10
# Change the default off keybinding (F11)
set -g @remote-off-key F11
# Change the default toggle keybinding (F12)
set -g @remote-toggle-key F12
```

#### Indicator

The plugin never writes to `status-left` directly (so themes like catppuccin keep
their segments). It writes the badge to a dedicated option, `@remote-status`, and
**you** decide where it renders in your `.tmux.conf`:

```tmux
# AFTER your theme lines, e.g. after "#{E:@catppuccin_status_session}"
set -ag status-left "#{E:@remote-status}"
```

⚠️ Use the exact name `@remote-status` (hyphen, not underscore) — tmux treats
`@remote_status` as a different (unknown) option and renders nothing.

Upstream indicator options (used in default mode, `@remote-one-bar "off"`):

```tmux
# Change the indicator text (default: " REMOTE >>>  ")
set -g @remote-indicator-text " REMOTE >>>  "
# Change the indicator foreground color (default: colour228)
set -g @remote-indicator-fg "colour228"
# Change the indicator background color (default: colour52)
set -g @remote-indicator-bg "colour52"
```

### One-bar mode (nested sessions)

When `@remote-one-bar` is `on`, the parent and child bars stay **inverse**: exactly
one bar visible at a time, always the one of the server with keyboard focus.

```tmux
set -g @remote-one-bar "on"    # default: "off" (upstream behavior)
```

How it works:

- **Parent F10 (remote mode ON)** → parent hides its bar and sends the child-show
  key into the focused pane (`send-keys -t W.P`, which traverses ssh; `%pane_id`
  does **not**) → child shows its bar with the `REMOTE` badge.
- **Parent F11 (remote mode OFF)** → parent shows its bar with the `LOCAL` badge
  and sends the child-hide key → child hides its bar.

Both machines run this same plugin (the child needs it for the F8/F9 bindings).

Child-side options:

```tmux
# Key the parent sends to hide/show this server's bar (defaults F8 / F9)
set -g @remote-child-hide-key F8
set -g @remote-child-show-key F9
# Badge shown on the child's bar (default: " REMOTE >>>  ")
set -g @remote-child-indicator-text " REMOTE >>>  "
set -g @remote-child-indicator-fg "colour228"
set -g @remote-child-indicator-bg "colour52"
# Badge shown on the parent's bar in one-bar mode (default: " LOCAL >>>  ")
set -g @remote-local-indicator-text " LOCAL >>>  "
set -g @remote-local-indicator-fg "colour228"
set -g @remote-local-indicator-bg "colour31"
```

Result:

| Bar visible | Badge |
| --- | --- |
| Parent (local machine) | ` LOCAL >>>  ` |
| Child (ssh server) | ` REMOTE >>>  ` |

Known limitation: the signal key is sent to the **focused** pane. If focus is not
on the ssh pane when toggling, the key lands in the wrong pane.

## Testing
Tests run automatically via GitHub Actions on push and PR.

## Resources

- [Tmux in practice: local and nested remote tmux sessions](https://medium.freecodecamp.org/tmux-in-practice-local-and-nested-remote-tmux-sessions-4f7ba5db8795)
  Medium article by Alexey Samoshkin that inspired this plugin
- [Nested tmux](http://stahlke.org/dan/tmux-nested/)
  article by Dan Stahlke outlining the method for toggling keybindings

## License

[MIT](LICENSE.md)
