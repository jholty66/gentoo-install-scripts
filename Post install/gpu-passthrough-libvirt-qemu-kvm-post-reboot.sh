#/bin/sh
dmesg | grep 'IOMMU enabled'
while true; do
    read -p "Is IOMMU enabled?" yn
    case $yn in
        [Yy]* ) ;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
