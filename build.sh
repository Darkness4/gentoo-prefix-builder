#!/bin/sh
docker buildx build \
	--build-arg UID=1611 \
	--build-arg USER=marc \
	--build-arg GID=1600 \
	--build-arg GROUP=cluster-users \
	--build-arg EPREFIX=/mnt/nvmesh/gentoo-prefix \
	-t gentoo-builder .
