ARG UID=2001
ARG USER=gentoo-user
ARG GID=2001
ARG GROUP=gentoo-group
ARG EPREFIX=/gentoo

FROM ubuntu:21.04

ARG UID
ARG GID
ARG EPREFIX
ARG USER
ARG GROUP

# Check ubuntu glibc version : https://launchpad.net/ubuntu/+source/glibc
# Check gentoo glibc version : https://packages.gentoo.org/packages/sys-libs/glibc
# They must match
RUN apt update -y && apt install -y build-essential wget && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GID} ${GROUP} && useradd -u ${UID} -g ${GROUP} ${USER}
RUN mkdir -p ${EPREFIX} && chmod 775 ${EPREFIX} && chown ${UID}:${GID} ${EPREFIX}

RUN wget https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh -qO /usr/bin/bootstrap-prefix.sh && chmod +x /usr/bin/bootstrap-prefix.sh

WORKDIR ${EPREFIX}
USER ${USER}:${GROUP}
ENV EPREFIX=${EPREFIX}

CMD ["/usr/bin/bootstrap-prefix.sh"]

