#!/usr/bin/env bash
CONFIG=""
if [ -f "tools/cs-fixer/cs-fixer-config.php" ]; then
  CONFIG="--config=tools/cs-fixer/cs-fixer-config.php"
elif [ -f ".php-cs-fixer.php" ]; then
  CONFIG="--config=.php-cs-fixer.php"
elif [ -f ".php-cs-fixer.dist.php" ]; then
  CONFIG="--config=.php-cs-fixer.dist.php"
fi

TMPFILE=$(mktemp /tmp/php-cs-fixer.XXXXXX.php)
cat > "$TMPFILE"
php-cs-fixer fix $CONFIG --quiet --no-interaction "$TMPFILE" 2>/dev/null
cat "$TMPFILE"
rm -f "$TMPFILE"
