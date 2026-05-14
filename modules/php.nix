{ pkgs, ... }:

let
  phpExtensions =
    { enabled, all }:
    enabled
    ++ (with all; [
      amqp
      gd
      pdo
      dom
      ast
      yaml
      intl
      xdebug
      curl
      apcu
      exif
      pgsql
      iconv
      sodium
      mysqli
      sqlite3
      openssl
      imagick
      mbstring
      calendar
      xmlwriter
      xmlreader
      tokenizer
      simplexml
      pdo_mysql
      pdo_pgsql
      pdo_sqlite
      ctype
      filter
      session
    ]);

  phpConfig = ''
    xdebug.mode=develop
    # xdebug.start_with_request=yes
    memory_limit = 2G
  '';

  myPhp85 = pkgs.php85.buildEnv {
    extensions = phpExtensions;
    extraConfig = phpConfig;
  };

  myPhp84 = pkgs.php84.buildEnv {
    extensions = phpExtensions;
    extraConfig = phpConfig;
  };

  myPhp83 = pkgs.php83.buildEnv {
    extensions = phpExtensions;
    extraConfig = phpConfig;
  };

in
{
  _module.args = {
    inherit myPhp83 myPhp84 myPhp85;
  };
}
