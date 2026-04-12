ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[yellow]%} 󰊢 "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[cyan]%} 󰊢 "

function prompt_char {
	if [ $UID -eq 0 ]; then echo "%{$fg[red]%}#%{$reset_color%}"; else echo "󰽺"; fi
}

PROMPT='%(?, ,%{$fg[red]%}FAIL%{$reset_color%}
)
%{$fg[cyan]%}⌈%{$reset_color%}%{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%}:%{$fg_bold[blue]%}%~%{$fg[cyan]%}⌋%{$reset_color%}$(git_prompt_info)
$(prompt_char) '

RPROMPT='%{$fg[green]%}[%*]%{$reset_color%}'
