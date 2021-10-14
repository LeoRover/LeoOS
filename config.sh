IMG_NAME="LeoOS"
IMG_VERSION="$(git describe --tags)"

export GIT_REPO="https://github.com/LeoRover/LeoOS"
export GIT_HASH="$(git rev-parse HEAD)"
 
export TARGET_HOSTNAME="leo"
export FIRST_USER_NAME="pi"
export FIRST_USER_PASS="raspberry"
 
export LOCALE_DEFAULT="en_GB.UTF-8"
export KEYBOARD_KEYMAP="gb"
export KEYBOARD_LAYOUT="English (UK)"
export TIMEZONE_DEFAULT="Europe/London"
