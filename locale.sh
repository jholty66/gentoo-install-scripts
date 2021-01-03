set -e
source ./custom.sh
echo $LOCALE > /etc/locale.gen
locale-gen
source /etc/profile && env-update
