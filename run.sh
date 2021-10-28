#!/bin/sh

docker run -it --rm --name gentoo-builder \
	-v /mnt/nvmesh/gentoo-prefix:/mnt/nvmesh/gentoo-prefix \
	gentoo-builder

