ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[yellow]%} 󰊢 "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[cyan]%} 󰊢 "

function prompt_char {
  if [ $UID -eq 0 ]; then echo "%{$fg[red]%}#%{$reset_color%}"; else echo "󰽺"; fi
}

function calendar_prompt_info {
  local cache_file="$HOME/.cache/eureka-prompt/events.tsv"
  local display_cache="/tmp/eureka-prompt-calendar-display"
  local helper="/tmp/eureka-calendar-helper.sh"
  local now=$(date +%s)

  if [[ -f "$display_cache" ]]; then
    local cache_age=$((now - $(stat -c %Y "$display_cache")))
    if [[ $cache_age -lt 300 ]]; then
      cat "$display_cache"
      return
    fi
  fi

  [[ ! -f "$cache_file" ]] && return

  cat > "$helper" << SCRIPT
#!/usr/bin/env bash
now=$now
cutoff=\$((now + 900))
while IFS=\$'\t' read -r start_date start_time end_date end_time html_link hangout_link title; do
  [[ "\$start_date" == "start_date" ]] && continue
  event_start=\$(date -d "\$start_date \$start_time" +%s 2>/dev/null)
  event_end=\$(date -d "\$end_date \$end_time" +%s 2>/dev/null)
  [[ \$event_end -le \$now ]] && continue
  [[ \$event_start -gt \$cutoff ]] && continue
  url="\${hangout_link:-\$html_link}"
  time_span="\${start_time}-\${end_time}"
  if [[ -n "\$url" ]]; then
    printf '\033]8;;%s\033\\\\%s\033]8;;\033\\\\' "\$url" "\${time_span} \${title}"
  else
    printf '%s' "\${time_span} \${title}"
  fi
  break
done < "$cache_file"
SCRIPT

  bash "$helper" > "$display_cache"
  cat "$display_cache"
}

function _eureka_build_info_line {
  local cal="$(calendar_prompt_info)"
  local cyan=$'\e[0;36m'
  local magenta=$'\e[0;35m'
  local yellow=$'\e[0;33m'
  local blue=$'\e[1;34m'
  local bold_yellow=$'\e[1;33m'
  local reset=$'\e[0m'

  local left="${cyan}⌈${reset}${magenta}${USER}${reset}@${yellow}${HOST}${reset}:${blue}${PWD/#$HOME/~}${cyan}⌋${reset}"

  local git_branch="$(git symbolic-ref --short HEAD 2>/dev/null)"
  local git_part=""
  if [[ -n "$git_branch" ]]; then
    local git_dirty="$(git status --porcelain 2>/dev/null)"
    if [[ -n "$git_dirty" ]]; then
      git_part="${bold_yellow} ${git_branch} 󰊢 ${reset}"
    else
      git_part="${cyan} ${git_branch} 󰊢 ${reset}"
    fi
  fi

  local full_left="${left}${git_part}"

  if [[ -n "$cal" ]]; then
    local cal_plain=$(printf '%s' "$cal" | sed $'s/\033]8;;[^\033]*\033\\\\//g' | sed $'s/\033[[0-9;]*m//g')
    local left_plain=$(printf '%s' "$full_left" | sed $'s/\033[[0-9;]*m//g')
    local cal_len=${#cal_plain}
    local left_len=${#left_plain}
    local pad=$(( COLUMNS - left_len - cal_len - 1 ))
    if [[ $pad -gt 0 ]]; then
      printf '\n%s%*s%s\n' "$full_left" "$pad" "" "$cal"
    else
      printf '\n%s %s\n' "$full_left" "$cal"
    fi
  else
    printf '\n%s\n' "$full_left"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _eureka_build_info_line

PROMPT='%(?,,%{$fg[red]%}FAIL%{$reset_color%}
)$(prompt_char) '

RPROMPT='%{$fg[green]%}[%*]%{$reset_color%}'
