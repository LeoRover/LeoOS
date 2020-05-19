#!/bin/bash -e

usage()
{
	echo "Usage: $0 [ -f FIRST ] [ -l LAST ] [ -c ]" 1>&2 
}

exit_abnormal() 
{
	usage
	exit 1
}

run_sub_stage()
{
	log "Begin ${SUB_STAGE_DIR}"
	pushd "${SUB_STAGE_DIR}" > /dev/null

	for i in {00..99}; do
		if [ -f "${i}-debconf" ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-debconf"
			on_chroot << EOF
debconf-set-selections <<SELEOF
$(cat "${i}-debconf")
SELEOF
EOF
			log "End ${SUB_STAGE_DIR}/${i}-debconf"
		fi

		if [ -f "${i}-packages-nr" ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-packages-nr"
			PACKAGES="$(sed -f "${SCRIPT_DIR}/remove-comments.sed" < "${i}-packages-nr")"
			if [ -n "$PACKAGES" ]; then
				on_chroot << EOF
apt-get -o APT::Acquire::Retries=3 install --no-install-recommends -y $PACKAGES
EOF
			fi
			log "End ${SUB_STAGE_DIR}/${i}-packages-nr"
		fi

		if [ -f "${i}-packages" ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-packages"
			PACKAGES="$(sed -f "${SCRIPT_DIR}/remove-comments.sed" < "${i}-packages")"
			if [ -n "$PACKAGES" ]; then
				on_chroot << EOF
apt-get -o APT::Acquire::Retries=3 install -y $PACKAGES
EOF
			fi
			log "End ${SUB_STAGE_DIR}/${i}-packages"
		fi

		if [ -d "${i}-patches" ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-patches"
			pushd "${STAGE_WORK_DIR}" > /dev/null
			if [ "${CLEAN}" = "1" ]; then
				rm -rf .pc
				rm -rf ./*-pc
			fi
			QUILT_PATCHES="${SUB_STAGE_DIR}/${i}-patches"
			SUB_STAGE_QUILT_PATCH_DIR="$(basename "$SUB_STAGE_DIR")-pc"
			mkdir -p "$SUB_STAGE_QUILT_PATCH_DIR"
			ln -snf "$SUB_STAGE_QUILT_PATCH_DIR" .pc
			quilt upgrade
			if [ -e "${SUB_STAGE_DIR}/${i}-patches/EDIT" ]; then
				echo "Dropping into bash to edit patches..."
				bash
			fi
			RC=0
			quilt push -a || RC=$?
			case "$RC" in
				0|2)
					;;
				*)
					false
					;;
			esac
			popd > /dev/null
			log "End ${SUB_STAGE_DIR}/${i}-patches"
		fi

		if [ -x ${i}-run.sh ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-run.sh"
			./${i}-run.sh
			log "End ${SUB_STAGE_DIR}/${i}-run.sh"
		fi

		if [ -f ${i}-run-chroot.sh ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-run-chroot.sh"
			on_chroot < ${i}-run-chroot.sh
			log "End ${SUB_STAGE_DIR}/${i}-run-chroot.sh"
		fi
	done

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
	rm -rf "${STAGE_WORK_DIR}"
	mkdir -p "${STAGE_WORK_DIR}"

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
export IMG_TIME="$(date +%H-%M-%S)"

export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR="${BASE_DIR}/scripts"
export WORK_DIR="${BASE_DIR}/work/${IMG_DATE}-${IMG_TIME}"
export DEPLOY_DIR="${BASE_DIR}/deploy"
export LOG_FILE="${WORK_DIR}/build.log"

export STAGE
export STAGE_DIR
export STAGE_WORK_DIR
export PREV_STAGE
export PREV_STAGE_DIR
export ROOTFS_DIR
export PREV_ROOTFS_DIR

source "${BASE_DIR}/config"

export IMG_FILENAME="${IMG_NAME}-${IMG_VERSION}-${IMG_DATE}"

source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/dependencies_check.sh"

STAGE_FIRST=0
STAGE_LAST=99

while getopts ":f:l:c" options; do
	case "${options}" in
		f)
			STAGE_FIRST=${OPTARG}
			let STAGE_PREV=${STAGE_FIRST}-1 || true
			PREV_STAGE="stage${STAGE_PREV}"
			PREV_STAGE_DIR="${BASE_DIR}/${PREV_STAGE}"
			PREV_ROOTFS_DIR="${WORK_DIR}/${PREV_STAGE}"/rootfs
			;;
		l)
			STAGE_LAST=${OPTARG}
			;;
		c)
			PREV_WORK=$(ls -1 ${BASE_DIR}/work 2>/dev/null | tail -n 1)
			if [ ! -z "${PREV_WORK}" ]; then
				WORK_DIR="${BASE_DIR}/work/${PREV_WORK}"
				LOG_FILE="${WORK_DIR}/build.log"
			fi
			;;
		:)
			echo "Error: -${OPTARG} requires an argument."
			exit_abnormal
			;;
		*)
			exit_abnormal
			;;
	esac
done

dependencies_check "${BASE_DIR}/depends"

mkdir -p "${WORK_DIR}"
log "Begin ${BASE_DIR}"

for i in $(seq ${STAGE_FIRST} ${STAGE_LAST}); do
	if [ -d "${BASE_DIR}/stage${i}" ]; then
		STAGE_DIR="${BASE_DIR}/stage${i}"
		run_stage
	fi
done

for EXPORT_DIR in ${EXPORT_DIRS}; do
	STAGE_DIR=${BASE_DIR}/export-image
	source "${EXPORT_DIR}/EXPORT_IMAGE"
	EXPORT_ROOTFS_DIR=${WORK_DIR}/$(basename "${EXPORT_DIR}")/rootfs
	run_stage
done

log "End ${BASE_DIR}"
