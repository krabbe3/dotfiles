# Path to your Oh My Zsh installation.
export ZSH="$HOME/dotfiles/zsh/.oh-my-zsh"
# custom folder for themes
#export ZSH_CUSTOM="$ZSH"
export ZSH_CUSTOM="$HOME/dotfiles/zsh/custom"

# theme
ZSH_THEME="lomo"

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

# Select nvim as editor
export EDITOR='nvim'

# add VS Code to PATH variable
export MKL_NUM_THREADS=1
export OMP_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

# MAKALU69 has old nvim -> so use prebuild nvim 0.10.4 which is under ~/nvim/nvim_v0.10.4/bin/nvim if on Makalu as alias for nvim
# also lazygit alias, which lies in home/lazygit
if [[ "$(hostname -s)" == "makalu69" ]]; then
    alias lazygit="$HOME/lazygit/lazygit"
    export EDITOR="$HOME/nvim/nvim-v0.10.4/bin/nvim"
fi

# kitty +kitten ssh alias
# and automatic port forwarding for matplotlib webagg!
alias kssh="kitty +kitten ssh -L 8988:localhost:8988"

# extend path variable
export PATH="/Users/llm/.lmstudio/bin:$PATH"

# zsh plugin settings
# autosuggestions
# suggestion selection strategy
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# key bindings
# accept suggestion <C-y>
bindkey '^y' autosuggest-accept

# conda prompt
export CONDA_CHANGEPS1=false
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('~/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "~/miniforge3/etc/profile.d/conda.sh" ]; then
        . "~/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="~/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE='~/miniforge3/bin/mamba';
export MAMBA_ROOT_PREFIX='~/miniforge3';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
