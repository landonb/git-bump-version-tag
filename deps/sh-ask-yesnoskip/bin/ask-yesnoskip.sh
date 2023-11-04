#!/bin/sh
# vim:tw=0:ts=2:sw=2:et:norl:ft=sh
# Project: https://github.com/landonb/sh-ask-yesnoskip#😷
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# Set SKIP_PROMPTS=true to auto-respond 's'kip.

# Set SKIP_PROMPT_NL=true to suppress the blank echo line.

ask_yesnoskip () {
  local the_ask="$1"
  local default_choice="${2:-N}"
  local audit_choice="$3"

  # ***

  if [ "${default_choice}" = "Y" ]; then
    lng_opts='Yes/no/skip'
    sht_opts='Y/n/s'
  elif [ "${default_choice}" = "N" ]; then
    lng_opts='yes/No/skip'
    sht_opts='y/N/s'
  elif [ "${default_choice}" = "S" ]; then
    lng_opts='yes/no/Skip'
    sht_opts='y/n/S'
  else
    >&2 echo "ASSERT: Unrecognized default_choice: ${default_choice}"

    return 1
  fi

  ${SKIP_PROMPT_NL:-false} || >&2 echo
  >&2 printf %s "Please ${lng_opts}: ${the_ask}? [${sht_opts}] "

  # ***

  local the_choice

  if [ -z "${audit_choice}" ]; then
    ${SKIP_PROMPTS:-false} \
      && the_choice='s' \
      || read -e the_choice
  else
    the_choice="${audit_choice}"
  fi

  # Use default if nothing input.
  [ -z "${the_choice}" ] \
    && the_choice="${default_choice}"

  # Lowercase the input.
  the_choice="${the_choice,,}"

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

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

