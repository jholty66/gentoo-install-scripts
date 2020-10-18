#!/bin/sh
### Custom variables
GITDIR=$(pwd)
USER=charile

### Add users with sudo privlages
echo ""
echo "Installing sudo."
echo ""
emerge --ask=n sudo
echo ""
echo "Modify sudoers file."
echo ""
nano /etc/sudoers
useradd -m -G wheel,audio,video $USER
echo ""
echo "Set user password."
echo ""
passwd $USER

### Setup Emacs
# Add emacs use fag to "/etc/portage/make.conf"
echo ""
echo "Installing Emacs."
echo ""
time emerge --ask=n emacs
git clone https://gitub.com/jholty66/.emacs.d.git /home/$USER/.emacs.d/

### Change portage to use git instead of rsync
mv /etc/portage/repos.conf/gentoo.conf /etc/portage/repos.conf/gentoo.conf.def
cp $GITDR/gentoo.conf /etc/portage/repos.conf/gentoo.conf
mv /var/db/repos/gentoo{,.bak}
mkdir /var/db/repos/gentoo
emerge --sync
# Remove "/var/db/repos/gentoo.bak" manually

### Portage optimizations
emerge ccache app-portage/cpuid2cpuflags sys-devel/distcc

### Ccache
mkdir -p /var/cache/ccache
chown root:portage /var/cache/ccache
chmod 2775 /var/cache/ccache
cp $GITDIR/ccache.conf /var/cache/ccache/ccache.conf
echo ""
echo "Add the following toe /etc/portage/make.conf:"
echo ""
echo "FEATURES=\"ccache\""
echo "CCACHE_DIR=\"/var/cache/ccache\""
touch /etc/profile.d/ccache
echo "export PATH=\"/usr/lib/ccache/bin${PATH:+:}$PATH\"" > /etc/profile.d/ccache
echo "export CCACHE_DIR=\"/var/cache/ccache\"" > /etc/profile.d/ccache
. /etc/profile.d/ccache.sh

# cpuid2cpuflags
cpuid2cpuflags
