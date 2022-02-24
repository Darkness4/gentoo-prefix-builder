ARG uid=2001
ARG user=gentoo-user
ARG gid=2001
ARG group=gentoo-group
ARG eprefix=/gentoo

FROM quay.io/fedora/fedora:34

ARG uid
ARG gid
ARG eprefix
ARG user
ARG group

# Check ubuntu glibc version : https://pkgs.org/search/?q=glibc
# Check gentoo glibc version : https://packages.gentoo.org/packages/sys-libs/glibc
# They must match. This is pretty much why we are using fedora.
RUN dnf install -y @development-tools \
  gcc \
  gcc-c++ \
  sudo \
  wget \
  perl-core \
  rsync \
  zstd \
  && dnf clean all

RUN groupadd -g ${gid} ${group} && useradd -u ${uid} -g ${group} ${user}
RUN mkdir -p ${eprefix} && chmod 775 ${eprefix} && chown ${uid}:${gid} ${eprefix}

RUN wget https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-bash.sh -qO /tmp/bootstrap-bash.sh \
  && chmod +x /tmp/bootstrap-bash.sh \
  && /tmp/bootstrap-bash.sh /var/tmp/bash

# Last seds appply fixes to bootstrap script
RUN wget https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh -qO /usr/bin/bootstrap-prefix.sh \
  && chmod +x /usr/bin/bootstrap-prefix.sh \
  && sed -i 's/$(type -P gcc)/gcc/g' /usr/bin/bootstrap-prefix.sh \
  && sed -i 's/$(type -P g++)/g++/g' /usr/bin/bootstrap-prefix.sh \
  && sed -i 's/m4 1.4.18/m4 1.4.19/g' /usr/bin/bootstrap-prefix.sh \
  && sed -i 's/\[\[ \${PN} == "m4" \]\]/false/g' /usr/bin/bootstrap-prefix.sh

WORKDIR ${eprefix}
USER ${user}:${group}
ENV EPREFIX=${eprefix}
ENV GENTOO_MIRRORS=https://mirror.init7.net/gentoo/
ENV REPOS_MIRRORS=rsync://rsync.fr.gentoo.org/gentoo-portage/
ENV PATH="/var/tmp/bash/usr/bin:${PATH}"

CMD ["/usr/bin/bootstrap-prefix.sh"]
