#!/usr/bin/env bash

if [ $# -lt 4 ]; then
  echo "Usage: $0 <db_name> <db_user> <db_pass> <db_host> [wp_version] [skip_db_create]"
  exit 1
fi

# Arguments
DB_NAME=$1
DB_USER=$2
DB_PASS=$3
DB_HOST=${4-localhost}
WP_VERSION=${5-latest}
SKIP_DB_CREATE=${6-false}

# Paths
WP_TESTS_DIR=${WP_TESTS_DIR-/tmp/wordpress-tests-lib}
WP_CORE_DIR=${WP_CORE_DIR-/tmp/wordpress}

download() {
  if [ "$WP_VERSION" == "latest" ] || [ "$WP_VERSION" == "trunk" ]; then
    WP_VERSION="trunk"
  fi

  if [ ! -d $WP_CORE_DIR ]; then
    mkdir -p $WP_CORE_DIR
    wget -nv -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
    tar --strip-components=1 -zxmf /tmp/wordpress.tar.gz -C $WP_CORE_DIR
  fi
}

install_test_suite() {
  if [ ! -d $WP_TESTS_DIR ]; then
    mkdir -p $WP_TESTS_DIR
    # Always use 'trunk' for the test suite as 'latest' does not exist in tags.
    svn co --quiet https://develop.svn.wordpress.org/trunk/tests/phpunit/includes/ $WP_TESTS_DIR/includes
    svn co --quiet https://develop.svn.wordpress.org/trunk/tests/phpunit/data/ $WP_TESTS_DIR/data
  fi

  # Ensure the test includes directory exists
  if [ ! -f $WP_TESTS_DIR/includes/functions.php ]; then
    echo "Could not find WordPress test functions, failed to download test suite."
    exit 1
  fi

  # Create wp-tests-config.php
  CONFIG_FILE=$WP_TESTS_DIR/wp-tests-config.php

  cat > $CONFIG_FILE <<EOF
<?php
define( 'ABSPATH', '$WP_CORE_DIR/' );
define( 'DB_NAME', '$DB_NAME' );
define( 'DB_USER', '$DB_USER' );
define( 'DB_PASSWORD', '$DB_PASS' );
define( 'DB_HOST', '$DB_HOST' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );
define( 'WP_DEBUG', true );
define( 'WP_TESTS_DOMAIN', 'example.org' );
define( 'WP_TESTS_EMAIL', 'admin@example.org' );
define( 'WP_TESTS_TITLE', 'Test Blog' );
define( 'WP_PHP_BINARY', 'php' );
\$GLOBALS['wp_tests_options'] = array(
  'active_plugins' => array(),
);
EOF
}

install_db() {
  if [ "$SKIP_DB_CREATE" = "false" ]; then
    if ! mysql --user="$DB_USER" --password="$DB_PASS" --host="$DB_HOST" --execute="USE $DB_NAME;" 2>/dev/null; then
      mysqladmin create $DB_NAME --user="$DB_USER" --password="$DB_PASS" --host="$DB_HOST" --silent
    else
      echo "Database $DB_NAME already exists."
    fi
  fi
}

# Run functions
download
install_test_suite
install_db
