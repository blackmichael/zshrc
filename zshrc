# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Not sure why this doesn't work:
# source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Base
export HOSTNAME=$(hostname)
export VIM_EDITOR=mvim

# ZSH
DIRSTACKSIZE=15
HISTSIZE=50000
SAVEHIST=10000
HISTFILE=~/.history
WORDCHARS=${WORDCHARS//[-_.;\/]}
bindkey -e
setopt autopushd # turn cd into pushd for all situations 
setopt APPEND_HISTORY
setopt AUTO_CD # cd if no matching command
setopt EXTENDED_HISTORY # saves timestamps on history
setopt EXTENDED_GLOB # globs #, ~ and ^
setopt PUSHDMINUS       # make using cd -3 go to the 3rd directory history (dh) directory instead of having to use + (the default)
setopt AUTO_PUSHD 
setopt PUSHD_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE # don't put commands starting with a space in history
setopt AUTO_PARAM_SLASH # adds slash at end of tabbed dirs
setopt CHECK_JOBS # check bg jobs on exit
setopt CORRECT # corrects spelling
setopt GLOB_DOTS # find dotfiles easier
setopt HASH_CMDS # save cmd location to skip PATH lookup
setopt HIST_NO_STORE # don't save 'history' cmd in history
setopt HIST_IGNORE_DUPS # don't save duplicate entries in history
setopt INC_APPEND_HISTORY # append history as command are entered
setopt LIST_ROWS_FIRST # completion options left-to-right, top-to-bottom
setopt LIST_TYPES # show file types in list
setopt MARK_DIRS # adds slash to end of completed dirs
setopt NUMERIC_GLOB_SORT # sort numerically first, before alpha
setopt SHARE_HISTORY # share history between open shells
unsetopt beep
setopt auto_menu
setopt always_to_end
setopt complete_in_word
unsetopt flow_control
unsetopt menu_complete
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

## Fuzzy Finder Auto Completion
export FZF_PATH=$(brew --prefix)/opt/fzf
if [[ -d "/opt/homebrew/opt/fzf/shell" ]]; then
  FZF_SHELL="/opt/homebrew/opt/fzf/shell"
else
  FZF_SHELL="/usr/local/opt/fzf/shell"
fi

if [[ -d "$FZF_SHELL" ]]; then
  export FZF_CTRL_R_OPTS="--min-height=20 --exact --preview 'echo {}' --preview-window down:3:wrap"
  export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules,build}/*" 2> /dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  export FZF_CTRL_T_OPTS=$'--min-height=20 --preview \'[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file ||
                  (bat --style=numbers --color=always {} ||
                    cat {}) 2> /dev/null | head -500
  \''

  export FZF_DEFAULT_OPTS="
    --layout=reverse
    --info=inline
    --height=80%
    --bind '?:toggle-preview'
  "
  source "${FZF_SHELL}/completion.zsh" 2> /dev/null
  source "${FZF_SHELL}/key-bindings.zsh"
  alias fzfp="fzf $FZF_CTRL_T_OPTS"
  alias -g F='| fzfp'
  # needs findutils for gxargs and fd for better find
  # open a file somewhere under the current directory, press "?" for preview window
  open_fzf() {
    fd -t f -L -H -E ".git" |\
      fzf -m --min-height=20 \
        --preview-window=:hidden \
        --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -500' |\
      gxargs -ro -d "\n" open
  }
  zle     -N   open_fzf
  bindkey '^o' open_fzf
  # cd into a directory based on and fzf directory search
  cd_fzf() {
    local basedir=${1:-.} # default to starting from current directory (.) but allow override
    local directory
    if directory=$(fd -t d -L -H -I -E ".git" . "$basedir" | fzf --preview="tree -L 1 {}" ); then
      cd $directory && fzf-redraw-prompt
    fi
  }
  zle     -N   cd_fzf
  bindkey '^f' cd_fzf
  # cd into a directory somewhere under the home directory
  cd_home_fzf() {
    cd_fzf "$HOME"
  }
  zle     -N   cd_home_fzf
  # bindkey '\ef' cd_home_fzf  # meta-f (opt)
  # needs gxargs and fd - brew install findutils fd
  open_notes(){
    pushd -q "$NOTES_DIR"
    fd -t f -L -H -I -E ".git" | fzf -m | gxargs -ro -d "\n" mvim
    popd -q
  }
  zle     -N   open_notes
  bindkey '^n' open_notes
  jqpath_cmd='
  def path_str: [.[] | if (type == "string") then "." + . else "[" + (. | tostring) + "]" end] | add; 

    . as $orig |
      paths(scalars) as $paths |
      $paths |
      . as $path |
      $orig |
      [($path | path_str), "\u00a0", (getpath($path) | tostring)] |
      add
  '
  # pipe json in to use fzf to search through it for jq paths, uses a non-breaking space as an fzf column delimiter
  alias jqpath="jq -rc '$jqpath_cmd' | cat <(echo $'PATH\u00a0VALUE') - | column -t -s $'\u00a0' | fzf +s -m --header-lines=1"
  alias jqpathr="jq -rc '$jqpath_cmd'"
else
  echo "missing fzf: brew install fzf ripgrep bat fd findutils jq"
fi

# Go
export PATH="/usr/local/opt/go@1.19/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
export BAZEL_USE_CPP_ONLY_TOOLCHAIN=1

# Protobuf
export PATH="/opt/homebrew/opt/protobuf@3/bin:$PATH"

# Jump
eval "$(jump shell zsh)"

# Aliases
alias curltime="curl -sL -w '   namelookup: %{time_namelookup}\n      connect: %{time_connect}\n   appconnect: %{time_appconnect}\n  pretransfer: %{time_pretransfer}\n     redirect: %{time_redirect}\nstarttransfer: %{time_starttransfer}\n        total: %{time_total}\n' "
alias myip="curl icanhazip.com"
alias reload="source ~/.zshrc"
alias l="ls -alhH"
take() {
  mkdir -p $1 && cd $1
}

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# antidote (loads from ~/.config/zsh/.zsh_plugins.txt)
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load
autoload -Uz compinit && compinit -i

