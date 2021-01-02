set -e
source custom.sh
emerge app-portage/layman dev-vcs/git
layman -L
yes | layman -a zscheile
emerge --nodeps arch-install-scripts asciidoc
cp /etc/fstab /etc/fstab.bak /etc/fstab.def
genfstab -U -p / > /etc/fstab
cat /etc/fstab
