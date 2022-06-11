### Initialize Linux Home Environment ###
# Config Files
## vim
## tmux
## bashrc
#!/bin/bash

DIR=devenv
declare -A array
array[vim]=".vimrc"
array[tmux]=".tmux.conf"
array[bashrc]=".bashrc"
 
for i in "${!array[@]}"
do
    CONFIG=$i
    FILE=${array[$i]}
    FPATH="$HOME/$FILE"
    if test -L "$FPATH"; then
        echo "$FPATH: link exists."
    else
        echo "$CONFIG config does not exist"
        echo "Adding link"
        rm -f $FPATH
        ln -s $HOME/$DIR/$FILE $FPATH
    fi
done
