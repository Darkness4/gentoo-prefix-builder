#!/bin/sh
docker buildx build \
	--build-arg UID=2001 \
	--build-arg USER=gentoo-user \
	--build-arg GID=2001 \
	--build-arg GROUP=gentoo-group \
	--build-arg EPREFIX=/opt/gentoo \
	-t gentoo-builder .
