#!/bin/bash
__RED="\[$(tput setaf 1)\]"
__GREEN="\[$(tput setaf 2)\]"
__YELLOW="\[$(tput setaf 3)\]"
__NAVY="\[$(tput setaf 4)\]"
__PURPLE="\[$(tput setaf 5)\]"
__BLUE="\[$(tput setaf 6)\]"
__WHITE="\[$(tput setaf 7)\]"
__GRAY="\[$(tput setaf 8)\]"
__CLR_RESET="\[$(tput sgr0)\]"

export EDITOR=vim
export VISUAL=vim
export PAGER=less
export HISTCONTROL=ignoredups
export HISTIGNORE="bg:clear:exit:fg:history:ls:ll:pwd"

PROMPT_COMMAND=__prompt_command
__prompt_command() {
    __prompt_command_exitcode=$?
    # preliminary [user@host pwd]
    PS1="${__CLR_RESET}[${__GREEN}\u@\h ${__YELLOW}\W${__CLR_RESET}]"

    # display git branch name if available
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$GIT_BRANCH" ]; then
        PS1="$PS1 ${__BLUE}(${GIT_BRANCH}"
        if [ -n "$(git status --porcelain)" ]; then
            PS1="$PS1*" # '*' for changes
        #elif [ "$(git stash list)" ]; then
        #    PS1="$PS1!" # '!' for stash
        fi
        PS1="$PS1)${__CLR_RESET}"
    fi

    # display last exit code if unsuccessful.
    [ "$__prompt_command_exitcode" -ne 0 ] && PS1="$PS1 ${__RED}($__prompt_command_exitcode)${__CLR_RESET}"

    # display num of jobs
    __prompt_command_numjobs=$(jobs -r | wc -l)
    [ "$__prompt_command_numjobs" -ne 0 ] && PS1="$PS1 ${__GRAY}($__prompt_command_numjobs)${__CLR_RESET}"

    # display the suffix. % for normal users, # for the root
    if [ "$(id -u)" -ne 0 ]; then PS1="$PS1 % "; else PS1="$PS1 # "; fi
}

depclean() {
    pacman -Qqdt | sudo pacman -Rns -
    pacman -Qqd | sudo pacman -Rsu -
}

memclean() {
    killall helium
    killall electron
}

alias vi="vim"
alias ls='ls --color=auto'
alias ll='ls --color=auto -Glh'
alias grep='grep --color=auto'

if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi
