set -e
source ./custom.sh
emerge app-portage/layman dev-vcs/git
layman -L
yes | layman -a zscheile
emerge asciidoc
emerge --nodeps arch-install-scripts
cp /etc/fstab{,.bak}&&cp /etc/fstab{./def}
genfstab -U -p / > /etc/fstab
cat /etc/fstab
