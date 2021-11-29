#!/bin/sh
mkdir -p /tmp/gentoo
chmod 777 /tmp/gentoo
chown 2001:2001 /tmp/gentoo

docker run -it --rm --name gentoo-builder \
	-v /opt/gentoo:/opt/gentoo \
	-v /tmp/gentoo:/tmp/gentoo \
	-e PORTAGE_TMPDIR=/tmp/gentoo \
	gentoo-builder

