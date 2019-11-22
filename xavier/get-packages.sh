#! /bin/sh

# dowloads and unpacks .deb packages for defined arch
# this needs coreutils, dctrl-tools and wget added to
# build-packages when used via snapcraft.yaml

ARCH="arm64"

PKGLIST="$*"
echo "$(basename "$0"): obtaining packages for $ARCH: $PKGLIST"

case $ARCH in
    armhf|arm64)
        SERVER="http://ports.ubuntu.com"
        ;;
    *)
        SERVER="http://archive.ubuntu.com/ubuntu"
        ;;
esac

for pkg in $PKGLIST; do
    PKGPATH=""
    for POCKET in universe main; do
        PACKAGES="$SERVER/dists/xenial/$POCKET/binary-$ARCH/Packages.gz"
        UPACKAGES="$SERVER/dists/xenial-updates/$POCKET/binary-$ARCH/Packages.gz"
        if wget -q -O- $UPACKAGES | zcat | grep-dctrl -P "${pkg}" | grep Filename | grep -q "/${pkg}_"; then
            PKGPATH="$(wget -q -O- $UPACKAGES | zcat | grep-dctrl -P "${pkg}" |\
                grep Filename | grep "${pkg}_" | sed 's/^Filename: //')"
        elif wget -q -O- $PACKAGES | zcat | grep-dctrl -P "${pkg}" | grep Filename | grep -q "/${pkg}_"; then
            PKGPATH="$(wget -q -O- $PACKAGES | zcat | grep-dctrl -P "${pkg}" |\
                grep Filename | grep "${pkg}_" | sed 's/^Filename: //')"
        else
            PKGPATH=""
        fi
        if [ -n "$PKGPATH" ]; then
            echo "unpacking $pkg from $SERVER/$PKGPATH"
            wget -q -O- $SERVER/$PKGPATH | dpkg -x - unpack/
        fi
    done
done
