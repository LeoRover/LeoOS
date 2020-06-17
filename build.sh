#!/bin/bash -e

usage()
{
	echo "Usage: $0 [ -f FIRST ] [ -l LAST ] [ -c ] [ -d ] [ -e ] [ -x ]" 1>&2
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
$(envsubst < "${i}-debconf")
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

			export QUILT_PATCHES="${SUB_STAGE_DIR}/${i}-patches"
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
	ROOTFS_DIR="${STAGE_WORK_DIR}/rootfs"

	unmount "${STAGE_WORK_DIR}"

	if [ ! -f SKIP_IMAGES ]; then
		if [ -f "${STAGE_DIR}/EXPORT_IMAGE" ]; then
			EXPORT_STAGES="${EXPORT_STAGES} ${STAGE}"
		fi
	fi

	if [ ${STAGE} = "export-image" ] ||
		 [ ${STAGE_NR} -ge ${STAGE_FIRST} ] && [ ! -f SKIP ]; then

		if [ "${CLEAN}" = "1" ]; then
			if [ -d "${STAGE_WORK_DIR}" ]; then
				rm -rf "${STAGE_WORK_DIR}"
			fi
		fi
		mkdir -p "${STAGE_WORK_DIR}"
		
		if [ -x prerun.sh ]; then
			log "Begin ${STAGE_DIR}/prerun.sh"
			./prerun.sh
			log "End ${STAGE_DIR}/prerun.sh"
		fi
		for SUB_STAGE_DIR in "${STAGE_DIR}"/*; do
			if [ -d "${SUB_STAGE_DIR}" ]; then
				if [ ! -f "${SUB_STAGE_DIR}/SKIP" ]; then
					run_sub_stage
				else
					log "Skipping ${STAGE}/$(basename ${SUB_STAGE_DIR})"
				fi
			fi
		done
	else
		log "Skipping ${STAGE}"
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

export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR="${BASE_DIR}/scripts"

source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/dependencies_check.sh"

dependencies_check "${BASE_DIR}/depends"

STAGE_FIRST=0
STAGE_LAST=99
CONTINUE=0
CLEAN=1
EXPORT_IMAGES=1
COMPRESS_IMAGES=0

while getopts ":f:l:cdex" options; do
	case "${options}" in
		f)
			STAGE_FIRST=${OPTARG}
			;;
		l)
			STAGE_LAST=${OPTARG}
			;;
		c)
			CONTINUE=1
			;;
		d)
			CLEAN=0
			;;
		e)
			EXPORT_IMAGES=0
			;;
		x)
			COMPRESS_IMAGES=1
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

export GIT_REPO="https://github.com/LeoRover/leo_os"
export GIT_HASH="$(git rev-parse HEAD)"

export IMG_DATE="$(date +%Y-%m-%d)"
export IMG_TIME="$(date +%H-%M-%S)"

if [ "${CONTINUE}" = "1" ]; then
	PREV_WORK=$(ls -1 ${BASE_DIR}/work 2>/dev/null | tail -n 1)
fi

if [ ! -z "${PREV_WORK}" ]; then
	export WORK_DIR="${BASE_DIR}/work/${PREV_WORK}"
else
	export WORK_DIR="${BASE_DIR}/work/${IMG_DATE}-${IMG_TIME}"
fi

export DEPLOY_DIR="${BASE_DIR}/deploy"
export LOG_FILE="${WORK_DIR}/build.log"

export STAGE
export STAGE_DIR
export STAGE_WORK_DIR
export PREV_STAGE
export PREV_STAGE_DIR
export ROOTFS_DIR
export PREV_ROOTFS_DIR
export EXPORT_STAGE
export EXPORT_ROOTFS_DIR
export COMPRESS_IMAGES

source "${BASE_DIR}/config.sh"

export IMG_NAME
export IMG_VERSION
export BASE_IMG_URL
export TARGET_HOSTNAME
export FIRST_USER_NAME
export FIRST_USER_PASS
export LOCALE_DEFAULT
export KEYBOARD_KEYMAP
export KEYBOARD_LAYOUT
export TIMEZONE_DEFAULT

export IMG_FILENAME="${IMG_NAME}-${IMG_VERSION}-${IMG_DATE}"
export IMG_SUFFIX

mkdir -p "${WORK_DIR}"
log "Begin ${BASE_DIR}"

for i in $(seq 0 ${STAGE_LAST}); do
	if [ -d "${BASE_DIR}/stage${i}" ]; then
		STAGE_NR="${i}"
		STAGE_DIR="${BASE_DIR}/stage${i}"
		run_stage
	fi
done

if [ "${EXPORT_IMAGES}" = "1" ]; then
	CLEAN=1
	for EXPORT_STAGE in ${EXPORT_STAGES}; do
		STAGE_DIR=${BASE_DIR}/export-image
		source "${BASE_DIR}/${EXPORT_STAGE}/EXPORT_IMAGE"
		EXPORT_ROOTFS_DIR="${WORK_DIR}/${EXPORT_STAGE}/rootfs"
		run_stage
	done
fi

log "End ${BASE_DIR}"
