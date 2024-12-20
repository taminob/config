# .zshrc

bindkey -v # use vim keybindings

zstyle :compinstall filename '/home/me/.zshrc'

autoload -Uz compinit
compinit -u

# display if tab completion has no match
zstyle ':completion:*:warnings' format '%F{red}No matches%f'

ZSH_HOME=/home/me/sync/config/zsh
source "$ZSH_HOME/git.zsh"
if [ -f "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
	source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
else
	source "$ZSH_HOME/zsh-autosuggestions.zsh"
fi
if [ -f "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
	source "$ZSH_HOME/zsh-syntax-highlighting.zsh"
fi
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=magenta'
source "$ZSH_HOME/command-not-found.zsh"
source "$ZSH_HOME/agnoster.zsh-theme"

# initialize zoxide; cd ("z") alternative
if command -v zoxide 2>&1 >/dev/null ; then
	eval "$(zoxide init zsh)"
else
	echo "zoxide not available"
fi

# enable completion for ".."
zstyle ':completion:*' special-dirs true

#PROMPT='%F{green}%n%f@%F{magenta}%m%f %F{red}%B%~%b%f %# '
#RPROMPT='[%F{yellow}%?%f]'
setopt prompt_subst # allow functions in PROMPT
setopt interactivecomments # allow comments outside of scripts
setopt autocd # use "cd" in front of stand-alone path

HISTFILE=~/.zhistory
HISTSIZE=200000
SAVEHIST=100000
setopt hist_ignore_space # ignore commands in history starting with at least one space
#setopt share_history # share history between multiple instances; do not set inc_append_history at the same time
setopt inc_append_history # immediately write to history file, do not wait until exit
setopt hist_ignore_dups # do not record consecutive duplicates
setopt hist_expire_dups_first # delete duplicate entries first when trimming history

# always start in command mode (vicmd) instead of insert mode (viins)
#zle-line-init() { zle -K vicmd; }
#zle -N zle-line-init

#alias ls='ls --color=auto'
if command -v eza 2>&1 >/dev/null ; then
	alias ls='eza --header'
fi
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias mv='mv -vi'
alias cp='cp -vi'
alias ln='ln -v'
alias mkdir='mkdir -v'
if command -v nvim 2>&1 >/dev/null ; then
	alias vim='nvim'
fi
alias sudo='sudo ' # enable alias checking after sudo
alias lessh='LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s" less -R ' # enable src highlighting in less
#alias venv='source venv/bin/activate' # use functions to allow parameters
#alias open='xdg-open' # use functions to allow parameters

# generate shell completions
compdef _gnu_generic dua
compdef _gnu_generic eza
compdef _gnu_generic blkid

venv() {
	function get_venv_path()
	{
		venv_path="${1}"
		if [ ! "${venv_path}" ]; then
			venv_path="venv"
		fi
		echo "${venv_path}"
	}

	function activate_venv()
	{
		venv_path="${1}"
		source "${venv_path}"/bin/activate
	}

	if [ "${1}" = "exit" ]; then
		deactivate
	elif [ "${1}" = "create" ]; then
		venv_path="$(get_venv_path "${2}")"
		python -m venv "${venv_path}"
		activate_venv "${venv_path}"
	elif [ "${1}" = "jupyter" ]; then
		venv_path="$(get_venv_path "${2}")"
		activate_venv "${venv_path}"
		pip install jupyter jupyterlab-lsp
	else
		venv_path="$(get_venv_path "${1}")"
		activate_venv "${venv_path}"
	fi
}

open() {
	if [ ! "${OPEN_LIMIT}" ]; then
		OPEN_LIMIT=16
	fi
	if [ $# -gt "${OPEN_LIMIT}" ]; then
		echo "Trying to open ${#} different files - limit is set to ${OPEN_LIMIT}"
		return
	fi
	for arg in "${@}"; do
		xdg-open "${arg}" & # start them in parallel in background
	done
	for arg in "${@}"; do
		fg # bring them to foreground
	done
}

update() {
	# in case of failure, run:
	# sudo rm -vi /etc/pacman.d/gnupg &&
	# sudo pacman-key --init &&
	# sudo pacman-key --populate

	if [ "${1}" = "mirror" ] || [ "${1}" = "full" ]; then
		reflector --protocol https --latest 16 --fastest 8 --age 24 --sort rate --country France,Germany,Switzerland,Austria --verbose > /tmp/mirrorlist &&
		sudo \mv -i /tmp/mirrorlist /etc/pacman.d/mirrorlist &&
	elif [ "${1}" = "full" ]; then
		sudo pkgfile --update &&
	fi

	systemd-inhibit sudo pacman -Sy --noconfirm archlinux-keyring &&
	systemd-inhibit sudo pacman -Su
}

merge_dirs() {
	local src="${1}"
	local dest="${2}"
	if [ "${3}" = "-v" ] || [ "${4}" = "-v" ]; then
		local verbose=1
	elif [ "${3}" = "-vv" ] || [ "${4}" = "-vv" ]; then
		local verbose=2
	elif [ "${3}" = "-vvv" ] || [ "${4}" = "-vvv" ]; then
		local verbose=3
	fi
	if [ "${3}" = "--dry-run" ] || [ "${4}" = "--dry-run" ]; then
		echo "Do not perform filesystem changes"
		local dry_run=1
	fi

	local function merge_file() {
		local srcfile="${file}"
		local file="${file#"${src}/"}"
		if ! [ -f "${srcfile}" ]; then
			if [[ ${verbose} -ge 2 ]]; then
				echo "Not a file ${srcfile} - skipping..."
			fi
			continue
		fi
		if [[ ${verbose} -ge 3 ]]; then
			echo "Processing ${srcfile}..."
		fi

		local destfile="${dest}/${file}"
		if [ -e "${destfile}" ]; then
			if [ -f "${destfile}" ]; then
				if diff -q --binary "${srcfile}" "${destfile}" 2>&1 >/dev/null ; then
					if [[ ${verbose} -ge 3 ]]; then
						echo "Discarding ${srcfile}..."
					fi

					if [ ! ${dry_run} ]; then
						local trashdest="/tmp/merge_dirs_trash"
						\mkdir -p "${trashdest}/$(dirname "${file}")"
						\mv "${srcfile}" "${trashdest}/${file}"
					fi
					echo "discard ${srcfile}" >> "/tmp/merge_dirs_log"
				else
					if [[ ${verbose} -ge 3 ]]; then
						echo "Conflicting ${srcfile}..."
					fi

					echo "conflict ${srcfile}" >> "/tmp/merge_dirs_log"
				fi
			else
				if [[ ${verbose} -ge 3 ]]; then
					echo "Type conflicting ${srcfile}..."
				fi

				echo "typechange ${srcfile}" >> "/tmp/merge_dirs_log"
			fi
		else
			if [[ ${verbose} -ge 1 ]]; then
				local mkdir_options="-v"
				local mv_options="-v"
			fi

			if [ ! ${dry_run} ]; then
				local destdir="$(dirname "${destfile}")"
				\mkdir -p ${mkdir_options} "${destdir}"
				\mv ${mv_options} "${srcfile}" "${destfile}"
			fi
			echo "move ${srcfile}" >> "/tmp/merge_dirs_log"
		fi
	}

	echo "====== START $(date) ======" >> "/tmp/merge_dirs_log"
	for file in "${src}"/**/*(N) ; do
		merge_file "${file}"
	done
	for file in "${src}"/**/.*(N) ; do
		merge_file "${file}"
	done
	for file in "${src}"/**/.*/**/*(N) ; do
		merge_file "${file}"
	done
	for file in "${src}"/**/.*/**/.*(N) ; do
		merge_file "${file}"
	done
}

resume() {
	if [ "${1}" ]; then
		bg # continue in background
	else
		fg # continue in foreground
	fi
}

git_setup_repo() {
	git_url="${1}"
	target_directory="${2}"
	if [ ! "${git_url}" ]; then
		echo "Please specify git url as first argument!"
		return
	fi
	if [ ! "${target_directory}" ]; then
		target_directory="$(basename "${git_url}")"
		target_directory="${target_directory%.git}"
		echo "No target directory specified - falling back to '${target_directory}'!"
	fi
	if [ -d "${target_directory}" ]; then
		echo "'${target_directory}' does already exist!"
		return
	fi
	git clone --bare "${git_url}" "${target_directory}/.git" &&
	cd "${target_directory}" &&

	default_branch="$(git remote show origin | grep 'HEAD branch: ' | cut -d ' ' -f 5)" &&
	default_branch="$(echo "${default_branch}" | sed -e 's/\//_/g')" &&
	git worktree add "${default_branch}" "${default_branch}" &&
	cd "${default_branch}" &&
	git submodule update --init --recursive --progress
}

git_add_fork() {
	new_origin="${1}"
	if [ ! "${new_origin}" ]; then
		echo "Please specify git url of fork as first argument!"
		return
	fi
	upstream_remote="$(git remote get-url origin)" &&
	git remote set-url origin "${new_origin}" &&
	git remote add upstream "${upstream_remote}" &&

	git remote -v &&
	git fetch --all
}

docker_latest_bash() {
	docker exec -it "$(docker ps --latest --format "{{.ID}}")" bash
}

# custom shortcuts
bindkey '^[c' vi-cmd-mode # alt-c: enter cmd mode

# search history:
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
# OR
_history-incremental-search-backward () {
    zle .history-incremental-search-backward $BUFFER
}
zle -N history-incremental-search-backward _history-incremental-search-backward

# this line is actually not necessary since this is default.
bindkey '^R' history-incremental-search-backward

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
