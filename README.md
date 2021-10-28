# Preparation

## Dockerfile

```dockerfile
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
```

```sh
docker build -t gentoo-builder .
```

## Mkdir + chown output

```sh
mkdir gentoo
sudo chown 2001:2001 ./gentoo
```

## Lancer le script

```sh
docker run -it --rm --name gentoo-builder \
	-v $(pwd)/gentoo:/gentoo \
	gentoo-builder
```

```txt
Do you want me to start off now? [Yn]
How many parallel make jobs do you want? [8] 48
Do you want to use stable Prefix? [Yn] n
What do you want EPREFIX to be? [/gentoo]
Type here what you want to wish me [luck]
```

## Fixer la dépendance circulaire et le pwd

### Ignorer la dépendance en runtime `sys-libs/libxcrypt`

Le script va crasher à la première dépendance circulaire.

```txt
 * Error: circular dependencies:

(virtual/libcrypt-2:0/2::gentoo, ebuild scheduled for merge) depends on
 (sys-libs/libxcrypt-4.4.26:0/1::gentoo, ebuild scheduled for merge) (runtime)
  (dev-lang/perl-5.34.0-r5:0/5.34::gentoo, ebuild scheduled for merge) (buildtime)
   (virtual/libcrypt-2:0/2::gentoo, ebuild scheduled for merge) (buildtime_slot_op)

 * Note that circular dependencies can often be avoided by temporarily
 * disabling USE flags that trigger optional dependencies.
```

Nous allons fixer cette dépendance circulaire en plus de la non-détection de `libperl.so`.

```sh
mkdir -p ./gentoo/tmp/etc/portage/profile/
echo "sys-libs/libxcrypt-4.4.26" >> ./gentoo/tmp/etc/portage/profile/package.provided
```

Cela permet d'ignorer la dépendance `sys-libs/libxcrypt-4.4.26` qui est une dépendance en runtime.

### Détecter libperl.so

Modifiez `./gentoo/etc/portage/make.conf` et ajoutez :

```sh
LD_LIBRARY_PATH="/gentoo/usr/lib64:/gentoo/usr/lib:/gentoo/tmp/lib64:/gentoo/tmp/lib:/gentoo/tmp/usr/lib64:/gentoo/tmp/usr/lib"
```

### Mettre pwd

Faites `cp /bin/pwd ./gentoo/tmp/bin/pwd `

### Relancer

Relancer :

```sh
docker run -it --rm --name gentoo-builder \
	-v $(pwd)/gentoo:/gentoo \
	gentoo-builder
```

Si cela crash à un moment, retirez `$EPREFIX/tmp/etc/portage/profile/package.provided`.

Relancer le script avec les même paramètres. 


