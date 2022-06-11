### Initialize Linux Development Environment ###
# TOOLS
## vim
## tmux

FILE=~/.vimrc
if test -f "$FILE"; then
    echo "$FILE exists."
else
    ln -s .vimrc ~/.vimrc
fi
