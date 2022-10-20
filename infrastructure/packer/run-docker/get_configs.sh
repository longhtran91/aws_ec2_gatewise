#!/bin/bash

shopt -s expand_aliases
source ~/.bash_aliases

mkdir -p ~/gatewise/secrets/ssl ~/gatewise/secrets/web ~/gatewise/nginx/htpasswd

# ssl certs
aws secretsmanager get-secret-value --secret-id=wildcard.lhtran.com_ssl_key --query=SecretString --output=text >> ~/gatewise/secrets/ssl/privkey.pem
aws secretsmanager get-secret-value --secret-id=wildcard.lhtran.com_ssl_fullchain_cert --query=SecretString --output=text >> ~/gatewise/secrets/ssl/fullchain.pem

# htpasswd for nginx
aws secretsmanager get-secret-value --secret-id=gatewise/nginx/htpasswd --query=SecretString --output=text >> ~/gatewise/nginx/htpasswd/nginx.htpasswd

# web tokens
cat << EOF > ~/gatewise/secrets/web/app.env
REFRESH_TOKEN=$(aws secretsmanager get-secret-value --secret-id gatewise/web --query SecretString --output=text | jq -r '.refresh_token')
USER_AGENT=$(aws secretsmanager get-secret-value --secret-id gatewise/web --query SecretString --output=text | jq -r '.user_agent')
DEVICE_TOKEN=$(aws secretsmanager get-secret-value --secret-id gatewise/web --query SecretString --output=text | jq -r '.device_token')
KEY=$(aws secretsmanager get-secret-value --secret-id gatewise/web --query SecretString --output=text | jq -r '.key')
EOF

# set proper permissions for secrets 700 for dir and 600 for files
chmod -R u=rwX,g=,o= ~/gatewise/secrets


# get parameters for nginx
cat << EOF > ~/gatewise/nginx/host.env
HOSTNAME=$(aws ssm get-parameter --name /gatewise/nginx/hostname-alt | jq -r '.Parameter.Value')
SSL_CERT_FILE_PATH=$(aws ssm get-parameter --name /gatewise/nginx/ssl_cert_file_path | jq -r '.Parameter.Value')
SSL_CERT_KEY_PATH=$(aws ssm get-parameter --name /gatewise/nginx/ssl_key_file_path | jq -r '.Parameter.Value')
EOF




