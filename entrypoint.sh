#!/bin/bash

if [ ! -e "${EPREFIX}/.stage1-finished" ]; then
  STOP_BOOTSTRAP_AFTER=stage1 LATEST_TREE_YES=1 STABLE_PREFIX=yes /usr/bin/bootstrap-prefix.sh noninteractive

  cat <<EOF >>"${EPREFIX}/etc/portage/repos.conf"
[gentoo]
sync-type = rsync
sync-uri = ${REPOS_MIRRORS}
EOF

  cat <<EOF >>"${EPREFIX}/tmp/etc/portage/repos.conf"
[gentoo]
sync-type = rsync
sync-uri = ${REPOS_MIRRORS}
EOF

  cat <<EOF >/opt/gentoo/etc/portage/make.conf/0101_mirrors_make.conf
GENTOO_MIRRORS="${GENTOO_MIRRORS}"
EOF

  cat <<EOF >/opt/gentoo/tmp/etc/portage/make.conf/0101_mirrors_make.conf
GENTOO_MIRRORS="${GENTOO_MIRRORS}"
EOF
fi

LATEST_TREE_YES=1 STABLE_PREFIX=yes /usr/bin/bootstrap-prefix.sh noninteractive
