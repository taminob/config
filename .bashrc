#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

#alias ls='ls --color=auto'
alias ls='exa -h'
alias vim='nvim'

source /usr/share/doc/pkgfile/command-not-found.bash

