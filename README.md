## Plugins

## Requirements

- xclip (for clipboard support)
- fd (for telescope)
- ripgrep (for telescope)
- Nerdfonts (for icons) (I use Hack Nerd Font)
- Neovim 0.5 or higher

Arch Linux:

```bash
sudo pacman -S xclip fd ripgrep
```

```bash
yay -S ttf-hack-nerd
```

## Installation

Clone this repository into your Neovim configuration directory.

Linux and MacOS:

```bash
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak ; git clone https://github.com/sontungexpt/neovim-config.git ~/.config/nvim --depth 1
```

Windows (git bash)

```bash
[ -d %USERPROFILE%/Local/nvim ] && mv %USERPROFILE%\AppData\Local\nvim %USERPROFILE%\AppData\Local\nvim.bak ; git clone https://github.com/sontungexpt/neovim-config.git %USERPROFILE%\AppData\Local\nvim --depth 1
```

You will also need to install the plugins. This configuration uses the lazy.nvim plugin manager to manage plugins. You can install the plugins by opening Neovim and running `:Lazy sync`

Install providers:

```bash
npm install -g neovim

gem install neovim

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install neovim
```

```vim
:Lazy sync
```

## Inspiration

- [NvChad](https://github.com/NvChad/NvChad)

## Configuration

This configuration is highly customizable and easy to configure. You can customize the configuration by modifying the init.lua file.

## Contributions

If you find any issues with this configuration or would like to contribute, please feel free to submit a pull request or open an issue.

## License

This configuration is licensed under the MIT license - see the [LICENSE](LICENSE) file for details.
