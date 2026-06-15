#!/bin/env bash
## installss neomutt
sudo pacman -S neomutt curl isync msmtp pass ca-certificates gettext

# clone it
git clone https://github.com/LukeSmithxyz/mutt-wizard

# get into there !
cd mutt-wizard || exit

## install it !
sudo make install
