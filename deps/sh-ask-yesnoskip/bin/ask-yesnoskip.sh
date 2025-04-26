#!/bin/sh
# vim:tw=0:ts=2:sw=2:et:norl:ft=bash
# Project: https://github.com/landonb/sh-ask-yesnoskip#😷
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# Set SKIP_PROMPTS=true to auto-respond 's'kip.

# Set SKIP_PROMPT_NL=true to suppress the blank echo line.

ask_yesnoskip() {
  local the_ask="$1"
  local default_choice="${2:-N}"

  # ***

  if [ "${default_choice}" = "Y" ]; then
    lng_opts='[Y]es/no or skip'
    sht_opts='Y/n/s'
  elif [ "${default_choice}" = "N" ]; then
    lng_opts='yes/[N]o or skip'
    sht_opts='y/N/s'
  elif [ "${default_choice}" = "S" ]; then
    lng_opts='[S]kip or yes/no'
    sht_opts='y/n/S'
  else
    >&2 echo "ASSERT: Unrecognized default_choice: ${default_choice}"

    return 1
  fi

  ${SKIP_PROMPT_NL:-false} || >&2 echo
  >&2 printf "%s" "Please ${lng_opts}: ${the_ask}? [${sht_opts}] "

  # ***

  local the_choice

  if ${SKIP_PROMPTS:-false}; then
    the_choice='s'
  else
    read the_choice

    # On Linux (Bash v5), hitting Enter at the prompt doesn't print
    # a newline, so do so here. But on macOS (whether Bash v3 or
    # Bash v5) read prints the newline, so don't do so here.
    if [ -z "${the_choice}" ] && ! os_is_macos; then
      >&2 echo
    fi
  fi

  # Use default if nothing input.
  if [ -z "${the_choice}" ]; then
    the_choice="${default_choice}"
  fi

  # Lowercase the input.
  the_choice="$(echo "${the_choice}" | tr '[:upper:]' '[:lower:]')"

  # ***

  # We could consider just the first character:
  #   the_choice=${the_choice:0:1}
  # Or we could allow full and partial words (y, ye, yes, etc.).
  # But we don't. We require a one-character response.
  if [ "${the_choice}" != "y" ] && [ "${the_choice}" != "s" ]; then
    # Any input other than 'Y', 'y', 'S', or 's'.
    return 1
  fi

  # Prints either 'y' or 's'.
  printf %s "${the_choice}"
}

# ***

os_is_macos() {
  [ "$(uname)" = 'Darwin' ]
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
