#!/bin/sh

docker run -it --rm --name gentoo-builder \
	-v $(pwd)/gentoo:/gentoo \
	gentoo-builder

