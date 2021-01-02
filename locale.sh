set -e
source custom.sh
echo $LOCALE > /etc/locale.gen
locale-gen
env-update && source /etc/profile
