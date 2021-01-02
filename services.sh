set -e
source cusotm.sh
emerge $SERVICE_PACKAGES
for service in "$SERVICES"; do
	$INIT_ADD $service
done
