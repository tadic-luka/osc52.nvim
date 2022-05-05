# osc52.nvim

A Neovim 0.7+ plugin to copy text to the system clipboard from anywhere using
the [ANSI OSC52](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Operating-System-Commands)
sequence.

When this sequence is emitted by Neovim, the terminal will copy the given text into
the system clipboard. **This is totally location independent**, users can copy
from anywhere including from remote SSH sessions.

The only requirement is that the terminal must support the sequence. Here is a
non-exhaustive list of the status of popular terminal emulators regarding OSC52
(as of May 2021):

| Terminal | OSC52 support |
|----------|:-------------:|
| [Alacritty](https://github.com/alacritty/alacritty) | **yes** |
| [GNOME Terminal](https://github.com/GNOME/gnome-terminal) (and other VTE-based terminals) | [not yet](https://bugzilla.gnome.org/show_bug.cgi?id=795774) |
| [hterm (Chromebook)](https://chromium.googlesource.com/apps/libapps/+/master/README.md) | [**yes**](https://chromium.googlesource.com/apps/libapps/+/master/nassh/doc/FAQ.md#Is-OSC-52-aka-clipboard-operations_supported) |
| [iTerm2](https://iterm2.com/) | **yes** |
| [kitty](https://github.com/kovidgoyal/kitty) | **yes** |
| [screen](https://www.gnu.org/software/screen/) | **yes** |
| [Terminal.app](https://en.wikipedia.org/wiki/Terminal_(macOS)) | no, but see [workaround](https://github.com/roy2220/osc52pty) |
| [tmux](https://github.com/tmux/tmux) | **yes** |
| [Windows Terminal](https://github.com/microsoft/terminal) | **yes** |
| [rxvt](http://rxvt.sourceforge.net/) | **yes** (to be confirmed) |
| [urxvt](http://software.schmorp.de/pkg/rxvt-unicode.html) | **yes** (with a script, see [here](https://github.com/ojroques/vim-oscyank/issues/4)) |


So far it has been tested on (nvim version 0.7.0):
- MacOS + kitty
- MacOS + iterm2
- MacOS + alacritty
- Macos + alacritty + ssh + tmux (run OSCYank on nvim running in tmux on remote server)

## Installation
Make sure you have latest neovim version, which is 0.7+
With [Packer](https://github.com/wbthomason/packer.nvim):
```lua
use {
  'tadic-luka/osc52.nvim',
  config = [[require('osc52')]]
}
```

## Basic usage
Enter Visual mode, select your text and run `:OSCYank`.

You may want to map the command:
```vim
vnoremap <leader>c :OSCYank<CR>
```

You can also use the OSCYank operator:
```vim
nmap <leader>o <Plug>OSCYank
```

## Copying from a register
If you prefer to copy text from a particular register, use:
```vim
:OSCYankReg +  " this will copy text from register '+'
```

For the impatient one, copy this line to your config. Content will be copied to
clipboard after any yank operation:
```lua
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function(args)
      local event = vim.v.event
      if event.operator == "y" and event.regname == "" then
        vim.api.nvim_command('OSCYankReg "')
      end
    end,
    desc = "Copy yanked text to terminal clipboard using osc52 escape",
})
```

Or to copy to clipboard the `+` register (vim's *system clipboard* register):
```lua
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function(args)
      local event = vim.v.event
      if event.operator == "y" and event.regname == "" then
        vim.api.nvim_command('OSCYankReg +')
      end
    end,
    desc = "Copy register + to clipboard using osc52 escape",
})
```

## Configuration
Currently no configuration is available, but will be in the future versions.

## Credits
The code is derived from
[vim-oscyank](https://github.com/ojroques/vim-oscyank).

