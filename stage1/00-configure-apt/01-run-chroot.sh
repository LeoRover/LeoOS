add-apt-repository ppa:ubuntu-raspi2/ppa -y -n
add-apt-repository ppa:ubuntu-pi-flavour-makers/ppa -y -n
apt-get update
export FK_MACHINE="Raspberry Pi 4 Model B"
apt-get dist-upgrade -y
