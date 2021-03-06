DRIVER_NAME=rtl8812au
DRIVER_VERSION=5.7.0
KERNEL_VERSION=$(dpkg-query -W -f='${binary:Package}\n' linux-image-* | head -n 1 | sed 's/linux-image-//')
COMMIT_SHA=76c3cf81fdc71af4338571b6404beb2ba3835a62

cd /tmp
git clone -n https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au/
git checkout ${COMMIT_SHA}

sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/g' Makefile

cp -r $(pwd) /usr/src/${DRIVER_NAME}-${DRIVER_VERSION}

dkms add -m ${DRIVER_NAME} -v ${DRIVER_VERSION} -k ${KERNEL_VERSION} || true
dkms build -m ${DRIVER_NAME} -v ${DRIVER_VERSION} -k ${KERNEL_VERSION}
dkms install -m ${DRIVER_NAME} -v ${DRIVER_VERSION} -k ${KERNEL_VERSION}
