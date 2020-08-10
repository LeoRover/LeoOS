IMG_NAME="LeoOS"
IMG_VERSION="0.1-ERC"

export GIT_REPO="https://github.com/LeoRover/leo_os"
export GIT_HASH="$(git rev-parse HEAD)"

export BASE_IMG_URL=http://cdimage.ubuntu.com/releases/18.04.4/release/ubuntu-18.04.4-preinstalled-server-armhf+raspi3.img.xz
 
export TARGET_HOSTNAME="leo"
export FIRST_USER_NAME="pi"
export FIRST_USER_PASS="raspberry"
 
export LOCALE_DEFAULT="en_GB.UTF-8"
export KEYBOARD_KEYMAP="gb"
export KEYBOARD_LAYOUT="English (UK)"
export TIMEZONE_DEFAULT="Europe/London"
