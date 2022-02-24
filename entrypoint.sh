#!/bin/bash

if [ ! -e "${EPREFIX}/.stage1-finished" ]; then
  mkdir -p "${EPREFIX}/etc/portage/"
  cat <<EOF >>"${EPREFIX}/etc/portage/repos.conf"
[gentoo]
sync-type = rsync
sync-uri = ${REPOS_MIRRORS}
EOF

  mkdir -p "${EPREFIX}/tmp/etc/portage/"
  cat <<EOF >>"${EPREFIX}/tmp/etc/portage/repos.conf"
[gentoo]
sync-type = rsync
sync-uri = ${REPOS_MIRRORS}
EOF

  mkdir -p "${EPREFIX}/opt/gentoo/etc/portage/make.conf/"
  cat <<EOF >/opt/gentoo/etc/portage/make.conf/0101_mirrors_make.conf
GENTOO_MIRRORS="${GENTOO_MIRRORS}"
EOF

  mkdir -p "${EPREFIX}/opt/gentoo/etc/portage/make.conf/"
  cat <<EOF >/opt/gentoo/tmp/etc/portage/make.conf/0101_mirrors_make.conf
GENTOO_MIRRORS="${GENTOO_MIRRORS}"
EOF
fi

LATEST_TREE_YES=1 STABLE_PREFIX="${STABLE_PREFIX}" MAKEOPTS="${MAKEOPTS}" /usr/bin/bootstrap-prefix.sh "${EPREFIX}" noninteractive
