# .zshrc

bindkey -v # use vim keybindings

zstyle :compinstall filename '/home/me/.zshrc'

autoload -Uz compinit
compinit

ZSH_HOME=/home/me/sync/config/zsh
source $ZSH_HOME/git.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'
source $ZSH_HOME/command-not-found.zsh
source $ZSH_HOME/agnoster.zsh-theme

# enable completion for ".."
zstyle ':completion:*' special-dirs true

#PROMPT='%F{green}%n%f@%F{magenta}%m%f %F{red}%B%~%b%f %# '
#RPROMPT='[%F{yellow}%?%f]'
setopt prompt_subst # allow functions in PROMPT
setopt interactivecomments # allow comments outside of scripts
setopt autocd # use "cd" in front of stand-alone path

HISTFILE=~/.zhistory
HISTSIZE=20000
SAVEHIST=10000
setopt hist_ignore_space # ignore commands in history starting with at least one space
#setopt share_history # share history between multiple instances; do not set inc_append_history at the same time
setopt inc_append_history # immediately write to history file, do not wait until exit
setopt hist_ignore_dups # do not record consecutive duplicates
setopt hist_expire_dups_first # delete duplicate entries first when trimming history

# always start in command mode (vicmd) instead of insert mode (viins)
#zle-line-init() { zle -K vicmd; }
#zle -N zle-line-init

#alias ls='ls --color=auto'
alias ls='exa -h'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
#alias du='dua'
alias mv='mv -i'
alias cp='cp -i'
alias vim='nvim'
alias sudo='sudo ' # enable alias checking after sudo
alias lessh='LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s" less -R ' # enable src highlighting in less
#alias venv='source venv/bin/activate' # use functions to allow parameters
#alias open='xdg-open' # use functions to allow parameters

venv() {
	venv_path="$1"
	if [ -z "$1" ]; then
		venv_path="venv"
	fi
	if [ "$1" = "exit" ]; then
		deactivate
	elif [ "$1" = "create" ]; then
		python -m venv venv
	else
		source "$venv_path"/bin/activate
	fi
}

open() {
	MAX_PARALLEL=8
	echo "$@" | xargs -n 1 -P "$MAX_PARALLEL" xdg-open
}

update() {
	sudo pacman -Sy --noconfirm archlinux-keyring
	sudo pacman -Syu
}

# custom shortcuts
bindkey '^[c' vi-cmd-mode # alt-c: enter cmd mode

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete
[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

