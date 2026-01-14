# ~/.zshrc - Configuración de Zsh

# Cargar configuración del sistema
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
fi

# Configuración del PATH
export PATH=$HOME/.local/bin:$PATH

# Historia
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS

# Completado
autoload -Uz compinit
compinit

# Aliases generales
alias ll='lsd -alF'
alias la='lsd -A'
alias l='lsd -CF'
alias ls='lsd'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Aliases de Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# Aliases de sistema
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias search='pacman -Ss'
alias remove='sudo pacman -R'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

# Configuración de lsd
alias tree='lsd --tree'

# Configuraciones de herramientas
# Starship prompt (se carga al final)
eval "$(starship init zsh)"

# Atuin (reemplazo de history)
eval "$(atuin init zsh)"

# GitHub CLI completion
eval "$(gh completion -s zsh)"

# Configuración del editor
export EDITOR=nvim
export VISUAL=nvim

# Configuraciones adicionales
setopt AUTO_CD              # cd automático al escribir directorio
setopt GLOB_DOTS            # incluir archivos ocultos en glob
setopt EXTENDED_GLOB        # habilitar patrones extendidos
setopt NO_CASE_GLOB         # matching case-insensitive
setopt NUMERIC_GLOB_SORT    # ordenar archivos numéricamente

# Keybindings útiles
bindkey '^[[A' history-search-backward    # Flecha arriba
bindkey '^[[B' history-search-forward     # Flecha abajo