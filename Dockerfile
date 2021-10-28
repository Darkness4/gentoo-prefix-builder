FROM ubuntu:21.04

# Check ubuntu glibc version : https://launchpad.net/ubuntu/+source/glibc
# Check gentoo glibc version : https://packages.gentoo.org/packages/sys-libs/glibc
# They must match
RUN apt update -y && apt install -y build-essential wget && rm -rf /var/lib/apt/lists/*

ARG UID=2001
ARG GID=2001
RUN groupadd -g $GID gentoo-group && useradd -u $UID -g gentoo-group gentoo-user
RUN mkdir -p /gentoo && chmod 775 /gentoo && chown gentoo-user:gentoo-group /gentoo

RUN wget https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh -qO /usr/bin/bootstrap-prefix.sh && chmod +x /usr/bin/bootstrap-prefix.sh

WORKDIR /gentoo
USER gentoo-user:gentoo-group
ENV EPREFIX=/gentoo

CMD ["/usr/bin/bootstrap-prefix.sh"]
