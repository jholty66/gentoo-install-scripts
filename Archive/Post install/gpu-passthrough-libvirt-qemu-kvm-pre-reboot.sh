#/bin/sh
WORKINGDIRECTORY=$(pwd)
CORES=4
cd /usr/src/linux/
cp /usr/src/linux/.config /usr/src/linux/.config.back-$(date +%b-%d-%y)
cd $WORKINGDIRECTORY
sed -i 's/^.*IOMMU_SUPPORT.*$/IOMMU_SUPPORT=y/g' /usr/src/linux/.config
sed -i 's/^.*AMD_IOMMU.*$/AMD_IOMMU=y/g' /usr/src/linux/.config
sed -i 's/^.*AMD_IOMMU_V2.*$/AMD_IOMMU_V2=y/g' /usr/src/linux/.config
sed -i 's/^.*INTEL_IOMMU.*$/INTEL_IOMMU=y/g' /usr/src/linux/.config
sed -i 's/^.*INTEL_IOMMU_SVM.*$/INTEL_IOMMU_SVM=y/g' /usr/src/linux/.config
sed -i 's/^.*INTEL_IOMMU_DEFAULT_ON.*$/INTEL_IOMMU_DEFAULT_ON=y/g' /usr/src/linux/.config
sed -i 's/^.*IRQ_REMAP.*$/IRQ_REMAP=y/g' /usr/src/linux/.config
echo ""
echo "Compilng kernel."
echo ""
time (make -j$CORES && make_modules_install && make install)
while true; do
    read -p "Added \"iommu=pt intel_iommu=on pcie_acs_override=downstream,multifunction\" to bootloader?" yn
    case $yn in
        [Yy]* ) echo "Reboot computer.";;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
cd $WORKINGDIRECTORY
