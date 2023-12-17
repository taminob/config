# .zshenv

typeset -U PATH path
path=("$HOME/.cargo/bin/" "/opt/bin/" "/home/me/.local/bin" "$path[@]")
export PATH

export EDITOR=nvim
export LESSHISTFILE=- # disable less history
export GPG_TTY=${TTY} # set tty for gpg passphrase
export CMAKE_GENERATOR=Ninja
if [ -f "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env"
fi
