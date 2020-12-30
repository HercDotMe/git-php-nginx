#!/bin/bash

# Check if GIT_REPO is set
if [ -z "${GIT_REPO}" ]; then
    echo "GIT_REPO is unset"
    exit
fi

# Clone repository if not already cloned
if [ ! -f "/.git_cloned" ]; then
    rm -rfv /var/www/*
    git clone $GIT_REPO /var/www || exit
    cd /var/www/ || exit
    composer install --no-dev
    touch /.git_cloned
fi

# Reset config
cp /etc/nginx/conf.d/nginx_conf_template /etc/nginx/sites-available/default

# Replace parameters
sed -i 's:\[index_file\]:'"$INDEX_FILE"':g' /etc/nginx/sites-available/default
sed -i 's:\[document_root\]:'"$DOCUMENT_ROOT"':g' /etc/nginx/sites-available/default

# Execute CMD statement
exec "$@"