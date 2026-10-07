#!/usr/bin/env bash
CONFIG=""
AUTOLOAD=""
BIN="phpstan"

if [ -f "back/tools/phpstan/vendor/bin/phpstan" ]; then
  BIN="back/tools/phpstan/vendor/bin/phpstan"
elif [ -f "tools/phpstan/vendor/bin/phpstan" ]; then
  BIN="tools/phpstan/vendor/bin/phpstan"
elif [ -f "vendor/bin/phpstan" ]; then
  BIN="vendor/bin/phpstan"
fi

if [ -f "back/tools/phpstan/phpstan-config.neon" ]; then
  CONFIG="-c back/tools/phpstan/phpstan-config.neon"
elif [ -f "tools/phpstan/phpstan-config.neon" ]; then
  CONFIG="-c tools/phpstan/phpstan-config.neon"
elif [ -f "tools/phpstan/phpstan.neon" ]; then
  CONFIG="-c tools/phpstan/phpstan.neon"
elif [ -f "phpstan.neon" ]; then
  CONFIG="-c phpstan.neon"
elif [ -f "phpstan.neon.dist" ]; then
  CONFIG="-c phpstan.neon.dist"
fi

if [ -f "back/vendor/autoload.php" ]; then
  AUTOLOAD="-a back/vendor/autoload.php"
elif [ -f "vendor/autoload.php" ]; then
  AUTOLOAD="-a vendor/autoload.php"
fi

COMMAND="analyse"
case "$1" in
  analyse|analyze|clear-result-cache|dump-deps|help|list|worker|--version|-V)
    COMMAND="$1"
    shift
    ;;
esac

exec $BIN $COMMAND $CONFIG $AUTOLOAD "$@"
