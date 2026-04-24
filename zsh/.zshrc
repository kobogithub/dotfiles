# ~/.zshrc - Configuración de Zsh

# Cargar configuración del sistema
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
fi

# Configuración del PATH
export PATH=$HOME/.local/bin:$PATH
export PATH="/home/kobo/.cache/.bun/bin:$PATH"
export PATH="/home/kobo/go/bin:$PATH"
export PATH="/home/kobo/.local/bin:$PATH"

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
alias l='lsd -F'
alias ls='lsd'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias clima="curl wttr.in/Zarate"

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

# Nota: Los aliases de Kubernetes se cargan desde ~/.dotfiles/kubectl/.aliases_k8s

# Configuración de lsd
alias tree='lsd --tree'
alias lt='lsd --tree'
alias lh='lsd -lah'  # listado detallado con tamaños humanizados
alias lr='lsd -R'    # listado recursivo

# Configuraciones de herramientas
# Starship prompt (se carga al final)
eval "$(starship init zsh)"

# Atuin (reemplazo de history)
eval "$(atuin init zsh)"

# GitHub CLI completion
eval "$(gh completion -s zsh)"

# Zoxide (reemplazo inteligente de cd)
eval "$(zoxide init zsh --cmd cd)"
alias z='cd'  # Alias para usar z con zoxide

# # kubectl completion
# source <(kubectl completion zsh)
# complete -F __start_kubectl k

# Configuración del editor
export EDITOR=nvim
export VISUAL=nvim

# Configuraciones adicionales
setopt AUTO_CD              # cd automático al escribir directorio
setopt GLOB_DOTS            # incluir archivos ocultos en glob
setopt EXTENDED_GLOB        # habilitar patrones extendidos
setopt NO_CASE_GLOB         # matching case-insensitive
setopt NUMERIC_GLOB_SORT    # ordenar archivos numéricamente

# Cargar configuraciones de desarrollo
if [ -f "$HOME/.dotfiles/zsh/.aliases_general" ]; then
    source "$HOME/.dotfiles/zsh/.aliases_general"
fi

if [ -f "$HOME/.dotfiles/docker/.docker_aliases" ]; then
    source "$HOME/.dotfiles/docker/.docker_aliases"
fi

if [ -f "$HOME/.dotfiles/kubectl/.aliases_k8s" ]; then
    source "$HOME/.dotfiles/kubectl/.aliases_k8s"
fi

if [ -f "$HOME/.dotfiles/python/.python_config" ]; then
    source "$HOME/.dotfiles/python/.python_config"
fi

if [ -f "$HOME/.dotfiles/nodejs/.nodejs_config" ]; then
    source "$HOME/.dotfiles/nodejs/.nodejs_config"
fi

# Aliases de desarrollo adicionales
alias dev-status='dev-status'
alias dev-init='dev-init'
alias dev-clean='dev-clean'
alias code-ext='~/.dotfiles/vscode/install-extensions.sh'

# Keybindings útiles
bindkey '^[[A' history-search-backward    # Flecha arriba
bindkey '^[[B' history-search-forward     # Flecha abajo

# opencode
export PATH=/home/kobo/.opencode/bin:$PATH

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
export LANG=C.UTF-8
unset LC_ALL 2>/dev/null

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/kobo/google-cloud-sdk/path.zsh.inc' ]; then . '/home/kobo/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/kobo/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/kobo/google-cloud-sdk/completion.zsh.inc'; fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Secrets / env vars locales
[[ -f "$HOME/.env" ]] && source "$HOME/.env"
