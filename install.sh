# remove old docker version
apt-get remove docker docker-engine docker.io
apt-get update
apt-get install apt-transport-https ca-certificates  curl software-properties-common
# get Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# check GPG Key
#apt-key fingerprint 0EBFCD88
# Add docker repository
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce apache2-utils

# Install Docker-compose
# Update docker compose version check here https://github.com/docker/compose/releases
# for future reflection  https://github.com/docker/compose/releases/latest > redirect to https://github.com/docker/compose/releases/tag/1.21.2 
# replace tag by download ....
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

echo "Create Directories"
mkdir /var/dock
mkdir /var/dock/jdownloader
mkdir /var/dock/minio
mkdir /var/dock/traefik
mkdir /var/dock/traefik/acme
# Be careful Minio have restriction on folders names
mkdir /data
mkdir /data/downloads

echo "Define account for minio"
echo "Enter minio access key"
read MINIO_ACCESS
#MINIO_SECRET="$(htpasswd -n $MINIO_ACCESS)"

echo "Define account for minio"
echo "Enter minio secret"
read MINIO_SECRET

echo "Enter domain ex: example.com"
read DOMAIN
echo "Enter Email for let's encrypt certificate query"
read EMAIL

echo "Define Basic Auth account for traefik console"
echo "Enter traefik console username"
read REG_USERNAME
htpasswd -c .traefik_pwd $REG_USERNAME

echo "Define Basic Auth account for Jdownloader"
echo "Enter Jdownloader username"
read JD_USERNAME
htpasswd -c .jdownloader_pwd $JD_USERNAME

cp traefik.toml.ori /var/dock/traefik/traefik.toml
echo "Create /var/dock/traefik/traefik.toml configuration"
sed -i "s/%%DOMAIN%%/${DOMAIN}/g" /var/dock/traefik/traefik.toml
sed -i "s/%%EMAIL%%/${EMAIL}/g" /var/dock/traefik/traefik.toml
sed -i "s/%%BASIC_AUTH%%/$(cat .traefik_pwd)/g" /var/dock/traefik/traefik.toml

echo "Generate .env file"
ENV_FILE=".env"
touch "$ENV_FILE"
echo "DOMAIN=$DOMAIN" >> "$ENV_FILE"
echo "EMAIL=$EMAIL" >> "$ENV_FILE"
echo "MINIO_ACCESS=$MINIO_ACCESS" >> "$ENV_FILE"
#echo "MINIO_SECRET=${MINIO_SECRET##*:}" >> "$ENV_FILE"
echo "MINIO_SECRET=$MINIO_SECRET" >> "$ENV_FILE"
echo "JDOWNLOADER_BASIC_AUTH=$(cat .jdownloader_pwd)" >> "$ENV_FILE"

# CREATE DOCKER NETWORK
docker network create traefik

echo " -------------------------------------------------- "
echo " Start stack -> docker-compose up -d "
echo " -------------------------------------------------- "
echo " No errors on traefik console for get "
echo " Certificate -> edit /var/dock/traefik/traefik.toml "
echo " -------------------------------------------------- "
