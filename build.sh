#!/bin/bash -e

run_sub_stage()
{
	log "Begin ${SUB_STAGE_DIR}"
	pushd "${SUB_STAGE_DIR}" > /dev/null
# 	for i in {00..99}; do
# 		if [ -f "${i}-debconf" ]; then
# 			log "Begin ${SUB_STAGE_DIR}/${i}-debconf"
# 			on_chroot << EOF
# debconf-set-selections <<SELEOF
# $(cat "${i}-debconf")
# SELEOF
# EOF

# 		log "End ${SUB_STAGE_DIR}/${i}-debconf"
# 		fi
# 		if [ -f "${i}-packages-nr" ]; then
# 			log "Begin ${SUB_STAGE_DIR}/${i}-packages-nr"
# 			PACKAGES="$(sed -f "${SCRIPT_DIR}/remove-comments.sed" < "${i}-packages-nr")"
# 			if [ -n "$PACKAGES" ]; then
# 				on_chroot << EOF
# apt-get -o APT::Acquire::Retries=3 install --no-install-recommends -y $PACKAGES
# EOF
# 			fi
# 			log "End ${SUB_STAGE_DIR}/${i}-packages-nr"
# 		fi
# 		if [ -f "${i}-packages" ]; then
# 			log "Begin ${SUB_STAGE_DIR}/${i}-packages"
# 			PACKAGES="$(sed -f "${SCRIPT_DIR}/remove-comments.sed" < "${i}-packages")"
# 			if [ -n "$PACKAGES" ]; then
# 				on_chroot << EOF
# apt-get -o APT::Acquire::Retries=3 install -y $PACKAGES
# EOF
# 			fi
# 			log "End ${SUB_STAGE_DIR}/${i}-packages"
# 		fi
# 		if [ -d "${i}-patches" ]; then
# 			log "Begin ${SUB_STAGE_DIR}/${i}-patches"
# 			pushd "${STAGE_WORK_DIR}" > /dev/null
# 			if [ "${CLEAN}" = "1" ]; then
# 				rm -rf .pc
# 				rm -rf ./*-pc
# 			fi
# 			QUILT_PATCHES="${SUB_STAGE_DIR}/${i}-patches"
# 			SUB_STAGE_QUILT_PATCH_DIR="$(basename "$SUB_STAGE_DIR")-pc"
# 			mkdir -p "$SUB_STAGE_QUILT_PATCH_DIR"
# 			ln -snf "$SUB_STAGE_QUILT_PATCH_DIR" .pc
# 			quilt upgrade
# 			if [ -e "${SUB_STAGE_DIR}/${i}-patches/EDIT" ]; then
# 				echo "Dropping into bash to edit patches..."
# 				bash
# 			fi
# 			RC=0
# 			quilt push -a || RC=$?
# 			case "$RC" in
# 				0|2)
# 					;;
# 				*)
# 					false
# 					;;
# 			esac
# 			popd > /dev/null
# 			log "End ${SUB_STAGE_DIR}/${i}-patches"
# 		fi
# 		if [ -x ${i}-run.sh ]; then
# 			log "Begin ${SUB_STAGE_DIR}/${i}-run.sh"
# 			./${i}-run.sh
# 			log "End ${SUB_STAGE_DIR}/${i}-run.sh"
# 		fi
# 		if [ -f ${i}-run-chroot.sh ]; then
# 			log "Begin ${SUB_STAGE_DIR}/${i}-run-chroot.sh"
# 			on_chroot < ${i}-run-chroot.sh
# 			log "End ${SUB_STAGE_DIR}/${i}-run-chroot.sh"
# 		fi
# 	done
	popd > /dev/null
	log "End ${SUB_STAGE_DIR}"
}


run_stage(){
	log "Begin ${STAGE_DIR}"
	STAGE="$(basename "${STAGE_DIR}")"
	pushd "${STAGE_DIR}" > /dev/null

	STAGE_WORK_DIR="${WORK_DIR}/${STAGE}"
	ROOTFS_DIR="${STAGE_WORK_DIR}"/rootfs

	unmount "${STAGE_WORK_DIR}"

	if [ ! -f SKIP_IMAGES ]; then
		if [ -f "${STAGE_DIR}/EXPORT_IMAGE" ]; then
			EXPORT_DIRS="${EXPORT_DIRS} ${STAGE_DIR}"
		fi
	fi

	if [ ! -f SKIP ]; then
		if [ "${CLEAN}" = "1" ]; then
			if [ -d "${ROOTFS_DIR}" ]; then
				rm -rf "${ROOTFS_DIR}"
			fi
		fi
		if [ -x prerun.sh ]; then
			log "Begin ${STAGE_DIR}/prerun.sh"
			./prerun.sh
			log "End ${STAGE_DIR}/prerun.sh"
		fi
		for SUB_STAGE_DIR in "${STAGE_DIR}"/*; do
			if [ -d "${SUB_STAGE_DIR}" ] &&
			   [ ! -f "${SUB_STAGE_DIR}/SKIP" ]; then
				run_sub_stage
			fi
		done
	fi

	unmount "${STAGE_WORK_DIR}"
	
	PREV_STAGE="${STAGE}"
	PREV_STAGE_DIR="${STAGE_DIR}"
	PREV_ROOTFS_DIR="${ROOTFS_DIR}"

	popd > /dev/null
	log "End ${STAGE_DIR}"
}

if [ "$(id -u)" != "0" ]; then
	echo "Please run as root" 1>&2
	exit 1
fi

export IMG_DATE="$(date +%Y-%m-%d)"

export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR="${BASE_DIR}/scripts"
export WORK_DIR="${BASE_DIR}/work/${IMG_DATE}"
export DEPLOY_DIR="${BASE_DIR}/deploy"
export LOG_FILE="${WORK_DIR}/build.log"

source "${BASE_DIR}/config"

export IMG_FILENAME="${IMG_NAME}-${IMG_VERSION}-${IMG_DATE}"

source "${SCRIPT_DIR}/common"
source "${SCRIPT_DIR}/dependencies_check"

dependencies_check "${BASE_DIR}/depends"

mkdir -p "${WORK_DIR}"
log "Begin ${BASE_DIR}"

STAGE_LIST="${BASE_DIR}/stage*"

for STAGE_DIR in $STAGE_LIST; do
	STAGE_DIR=$(realpath "${STAGE_DIR}")
	run_stage
done

log "End ${BASE_DIR}"

# CLEAN=1
# for EXPORT_DIR in ${EXPORT_DIRS}; do
# 	STAGE_DIR=${BASE_DIR}/export-image
# 	# shellcheck source=/dev/null
# 	source "${EXPORT_DIR}/EXPORT_IMAGE"
# 	EXPORT_ROOTFS_DIR=${WORK_DIR}/$(basename "${EXPORT_DIR}")/rootfs
# 	run_stage
# 	if [ "${USE_QEMU}" != "1" ]; then
# 		if [ -e "${EXPORT_DIR}/EXPORT_NOOBS" ]; then
# 			# shellcheck source=/dev/null
# 			source "${EXPORT_DIR}/EXPORT_NOOBS"
# 			STAGE_DIR="${BASE_DIR}/export-noobs"
# 			run_stage
# 		fi
# 	fi
# done

# ----------------
# export PI_GEN=${PI_GEN:-pi-gen}
# export PI_GEN_REPO=${PI_GEN_REPO:-https://github.com/RPi-Distro/pi-gen}
# export USE_QEMU="${USE_QEMU:-0}"
# export ZIP_FILENAME="${ZIP_FILENAME:-"image_${IMG_DATE}-${IMG_NAME}"}"
# export DEPLOY_ZIP="${DEPLOY_ZIP:-1}"
# export RELEASE=${RELEASE:-buster}
# export WPA_ESSID
# export WPA_PASSWORD
# export WPA_COUNTRY
# export ENABLE_SSH="${ENABLE_SSH:-0}"
# export GIT_HASH=${GIT_HASH:-"$(git rev-parse HEAD)"}

# export CLEAN
# export IMG_NAME
# export APT_PROXY

# export STAGE
# export STAGE_DIR
# export STAGE_WORK_DIR
# export PREV_STAGE
# export PREV_STAGE_DIR
# export ROOTFS_DIR
# export PREV_ROOTFS_DIR
# export IMG_SUFFIX
# export NOOBS_NAME
# export NOOBS_DESCRIPTION
# export EXPORT_DIR
# export EXPORT_ROOTFS_DIR

# export QUILT_PATCHES
# export QUILT_NO_DIFF_INDEX=1
# export QUILT_NO_DIFF_TIMESTAMPS=1
# export QUILT_REFRESH_ARGS="-p ab"

# if [[ -n "${APT_PROXY}" ]] && ! curl --silent "${APT_PROXY}" >/dev/null ; then
# 	echo "Could not reach APT_PROXY server: ${APT_PROXY}"
# 	exit 1
# fi

# if [[ -n "${WPA_PASSWORD}" && ${#WPA_PASSWORD} -lt 8 || ${#WPA_PASSWORD} -gt 63  ]] ; then
# 	echo "WPA_PASSWORD" must be between 8 and 63 characters
# 	exit 1
# fi

# if [ -x ${BASE_DIR}/postrun.sh ]; then
# 	log "Begin postrun.sh"
# 	cd "${BASE_DIR}"
# 	./postrun.sh
# 	log "End postrun.sh"
# fi
