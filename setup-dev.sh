#!/bin/bash
set -e

# --- Detect Distro ---
echo "[+] Detecting Linux distribution..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "[!] Could not detect OS. Aborting."
    exit 1
fi

echo "[+] Detected distribution: $DISTRO"

# --- Install packages ---
echo "[+] Installing base packages..."

if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
    sudo apt update
    sudo apt install -y neovim zsh git curl ripgrep fd-find tmux
elif [[ "$DISTRO" == "fedora" || "$DISTRO" == "rhel" ]]; then
    sudo dnf install -y neovim zsh git curl ripgrep fd-find tmux
else
    echo "[!] Unsupported distro: $DISTRO"
    exit 1
fi

# --- Install vim-plug ---
echo "[+] Installing vim-plug for Neovim..."
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# --- Neovim config ---
echo "[+] Creating Neovim config with Telescope and themes..."

mkdir -p ~/.config/nvim

cat > ~/.config/nvim/init.vim << 'EOF'
call plug#begin('~/.local/share/nvim/plugged')

" Core
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Themes
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'morhetz/gruvbox'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'folke/tokyonight.nvim'
Plug 'rebelot/kanagawa.nvim'
Plug 'navarasu/onedark.nvim'
Plug 'sainnhe/everforest'
Plug 'shaunsingh/nord.nvim'
Plug 'rose-pine/neovim', { 'as': 'rose-pine' }
Plug 'lifepillar/vim-solarized8'

call plug#end()

syntax on
set number
set background=dark
set termguicolors
colorscheme dracula

lua << EOF2
require('telescope').setup {
  defaults = {
    file_ignore_patterns = { "node_modules", "%.git/" },
    layout_config = {
      horizontal = { preview_width = 0.5 },
    },
  }
}
EOF2

let mapleader = ","
nnoremap <leader>f <cmd>Telescope find_files<CR>
nnoremap <leader>g <cmd>Telescope live_grep<CR>
nnoremap <leader>b <cmd>Telescope buffers<CR>
nnoremap <leader>h <cmd>Telescope help_tags<CR>
EOF

echo "[+] Installing Neovim plugins..."
nvim +PlugInstall +qall

# --- Tmux config ---
echo "[+] Writing Tmux config..."
cat > ~/.tmux.conf << 'EOF'
set -g mouse on
set -g status-style bg=red
set -g pane-border-style fg=red
set -g pane-active-border-style bg=red,fg=red
setw -g mode-keys vi
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
EOF

# --- Oh My Zsh ---
echo "[+] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "[+] Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# --- Zsh Config ---
echo "[+] Writing .zshrc..."
cat > ~/.zshrc << 'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# === Path ===
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/arbeid/arm-gnu-toolchain/bin:$PATH"
export PATH="$HOME/gems/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# === Editor ===
alias vim='nvim'
export EDITOR='nvim'
export VISUAL='nvim'

# === Aliases ===
alias ll="ls -alh"
alias cdr="cd $HOME/arbeid/repo"
alias cda="cd $HOME/arbeid"
alias pi="ssh bib@10.0.0.239"
alias gda="/home/bib/arbeid/ghidra/ghidraRun"

# === Toolchain ===
export ARM_DIR="$HOME/arbeid/arm-gnu-toolchain"
export QEMU_LD_PREFIX="$HOME/arbeid/arm-toolchain-32/arm-none-linux-gnueabihf/libc"
alias JAVA_PATH="/usr/lib/jvm/java-21-openjdk-21.0.4.0.7-2.fc40.x86_64"

# === Git Performance ===
DISABLE_UNTRACKED_FILES_DIRTY="true"

# === Locale ===
export LANG=en_US.UTF-8

# === Ruby ===
export GEM_HOME="$HOME/gems"

# === Powerlevel10k Config ===
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF

# --- Set Zsh as default ---
echo
read -p "Set Zsh as your default shell? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  chsh -s "$(which zsh)"
  echo "[✓] Zsh is now your default shell."
else
  echo "[i] Skipped setting Zsh as default."
fi

echo "[✓] Setup complete."
echo "    - Neovim with Telescope + 10 themes"
echo "    - Tmux with mouse and truecolor"
echo "    - Zsh with Powerlevel10k, aliases, and paths"

