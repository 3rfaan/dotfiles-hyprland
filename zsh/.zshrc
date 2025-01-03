#
# ███████╗███████╗██╗  ██╗██████╗  ██████╗
# ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝
#   ███╔╝ ███████╗███████║██████╔╝██║
#  ███╔╝  ╚════██║██╔══██║██╔══██╗██║
# ███████╗███████║██║  ██║██║  ██║╚██████╗
# ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#
# ZSH Config File by Arfan Zubi


# Autostart Hyprland at login
# if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
#     exec Hyprland
# fi

# Autostart sway at login
# if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
#     exec sway
# fi

# Aliases
alias q='exit'
alias ..='cd ..'
alias ls='eza -l -F --icons --hyperlink'
alias la='ls -a'
alias lla='ls -la'
alias t='tree'
alias rm='rm -v'
alias open='xdg-open'

alias v='nvim'
alias vi='nvim'
alias vim='nvim'

alias gs='git status'
alias ga='git add -A'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --all --decorate --graph --oneline --stat'

alias pu='sudo pacman -Syu'
alias pi='sudo pacman -S'
alias pr='sudo pacman -Rsu'
alias pq='sudo pacman -Qe'
alias autoclean='sudo pacman -Qtdq | sudo pacman -Rns - && yay -Sc'

alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias clippy='cargo clippy'

alias lock='hyprlock'
alias logout='loginctl terminate-user $USER'
alias standby='systemctl suspend'

alias ff='fastfetch'
alias b='bat'
alias z='zathura'

# Colored output
#alias ls='ls -laGH --color=auto'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'

# Colored pagers
export PAGER='less -RF'
export LESS='-R --use-color -Dd+r$Du+b'
export MANPAGER='less -R --use-color -Dd+r -Du+b'
#export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BAT_THEME='Catppuccin Mocha'

# Defaults
export TERM='tmux-256color'
export EDITOR='nvim'
export VISUAL='nvim'
export GTK_THEME="Adwaita:dark"

# File to store ZSH history
export HISTFILE=~/.zsh_history

# Number of commands loaded into memory from HISTFILE
export HISTSIZE=1000

# Maximum number of commands stores in HISTFILE
export SAVEHIST=1000

# Deno autocompletions
fpath+=($HOME/.zsh)

# Loading ZSH modules
autoload -Uz compinit && compinit

# Style control for completion system and VCS
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*' rehash true                      # Rehash so compinit can automatically find new executables in $PATH

# Match dotfiles without explicitly specifying the dot
_comp_options+=(globdots)

# Yazi shell
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    \rm -f -- "$tmp"
}

# ZSH profile
source ~/.profile

# XDG user dirs
source ~/.config/user-dirs.dirs

# Keybindings for FZF
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# ZSH Autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# ZSH Syntax Highlighting - must be at the end of .zshrc!
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Launch pfetch when opening new terminal
pfetch

# Starship prompt
eval "$(starship init zsh)"

