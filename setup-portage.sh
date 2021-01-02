set -e
source custom.sh
emerge-webrsync
emerge --update --deep --newuse @world
