# Path to your Oh My Zsh installation.
export ZSH="$HOME/dotfiles/zsh/.oh-my-zsh"
# custom folder for themes
#export ZSH_CUSTOM="$ZSH"
export ZSH_CUSTOM="$HOME/dotfiles/zsh/custom"

# theme
ZSH_THEME="lomo"

# add local bin to path
export PATH="$HOME/bin:$PATH"

# hyphen insensitive search (-_)
HYPHEN_INSENSITIVE="true"

# auto update behavior
zstyle ':omz:update' mode disabled      # update automatically without asking

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# change ZSH_CUSTOM to load custom plugins
#export ZSH_CUSTOM="$HOME/dotfiles/zsh/plugins"
plugins=(git conda-env zsh-autosuggestions fzf-zsh-plugin)

# zsh-syntax-highlighting has to be the last one
#plugins+=("zsh-syntax-highlighting")
# fast-syntax-highlighting
plugins+=("fast-syntax-highlighting")

source $ZSH/oh-my-zsh.sh

# export .local/bin for user packages
export PATH="$HOME/.local/bin:$PATH"
# Select nvim as editor
export EDITOR='nvim'

export MKL_NUM_THREADS=1
export OMP_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

# kitty +kitten ssh alias
# and automatic port forwarding for matplotlib webagg!
alias kssh="kitty +kitten ssh -L 8988:localhost:8988"

# zsh plugin settings
# autosuggestions
# suggestion selection strategy
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# key bindings
# accept suggestion <C-y>
bindkey '^y' autosuggest-accept

# add docker host env var
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

# ai sandbox stuff
alias aivim='PROJECT_DIR=$(pwd) PROJECT_NAME=$(basename "$PWD") docker compose -f ~/ai-sandbox/docker-compose.yml run --rm -it coder'

# conda stuff
# conda prompt
export CONDA_CHANGEPS1=false
# >>> Miniforge / Mamba initialization >>>
if [ -d "$HOME/miniforge3" ]; then
    # Initialize Conda/Mamba shell
    __conda_setup="$("$HOME/miniforge3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        export PATH="$HOME/miniforge3/bin:$PATH"
    fi
    unset __conda_setup

    # Activate base environment only after shell hook is loaded
    if [[ -z "$CONDA_DEFAULT_ENV" ]]; then
        conda activate
    fi
fi
# <<< Miniforge / Mamba initialization <<<
