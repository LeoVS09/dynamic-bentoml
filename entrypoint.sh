#!/usr/bin/env bash
set -Eeuo pipefail

# check to see if this file is being run or sourced from another script
_is_sourced() {
  # https://unix.stackexchange.com/a/215279
  [ "${#FUNCNAME[@]}" -ge 2 ] \
    && [ "${FUNCNAME[0]}" = '_is_sourced' ] \
    && [ "${FUNCNAME[1]}" = 'source' ]
}

_main() {
  # Overide the BENTOML_PORT if PORT env var is present. Used for Heroku
  if [[ -v PORT ]]; then
    echo "\$PORT is set! Overiding \$BENTOML_PORT with \$PORT ($PORT)"
    export BENTOML_PORT=$PORT \

    # Backward compatibility for BentoML prior to 0.7.5
    export BENTOML__APISERVER__DEFAULT_PORT=$PORT
  fi

  exec "$@"
}

if ! _is_sourced; then
  _main "$@"
fi
