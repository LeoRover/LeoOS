#!/bin/bash -e

install -v -m 644 files/leo-os-release "${ROOTFS_DIR}/etc/"

sed -i "
s|V_NAME|${IMG_NAME}|
s|V_VERSION|${IMG_VERSION}|
s|V_STAGE|${EXPORT_STAGE}|
s|V_DATE|${IMG_DATE}|
s|V_REPO|${GIT_REPO}|
s|V_HASH|${GIT_HASH}|
" "${ROOTFS_DIR}/etc/leo-os-release"