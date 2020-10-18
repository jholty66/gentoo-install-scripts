#/bin/sh
# Run as root
# Variables
CORES=4
USERNAME=charlie
WORKINGDIRECTORY=$(pwd)
# Main program
cd /usr/src/linux/
cp /usr/src/linux/.config /usr/src/linux/.config.back-$(date +%b-%d-%y)
sed -i 's/^.*CONFIG_HAVE_KVM.*$/CONFIG_HAVE_KVM=y/g' /usr/src/linux/.config
sed -i 's/^.*CONFIG_HAVE_KVM_IRQCHIP.*$/CONFIG_HAVE_KVM_IRQCHIP=y/g' /usr/src/linux/.config
sed -i 's/^.*CONFIG_HAVE_KVM_EVENTFD.*$/CONFIG_HAVE_KVM_EVENTFD=y/g' /usr/src/linux/.config
sed -i 's/^.*CONFIG_KVM.*$/CONFIG_KVM=y/g' /usr/src/linux/.config
sed -i 's/^.*CONFIG_KVM_INTEL.*$/CONFIG_KVM_INTEL=y/g' /usr/src/linux/.config # Change INTEL to AMD if on AMD CPU
echo ""
echo "Compiling Kernel."
echo ""
time (make -j$CORES ; make && modules_install && make install)
echo "QEMU_SOFTMMU_TARGETS=\"arm x86_64 sparc\""
echo "QEMU_USER_TARGETS=\"x86_64\""
echo ""
echo "Emerging qemu."
echo ""
echo "app-emulation/qemu gtk" > /etc/portage/package.use
time emerge --ask app-emulation/qemu
gpasswd -a charlie
echo ""
echo "Qemu is configured"
echo ""
cd $WORKINGDIRECTORY
