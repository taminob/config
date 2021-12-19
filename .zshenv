# .zshenv

typeset -U PATH path
path=("$HOME/.cargo/bin/" "/opt/bin/" "$path[@]")
export PATH

export EDITOR=nvim
export LESSHISTFILE=- # disable less history
