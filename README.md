# Preparation

## Export

Out installation path is `/usr/local/gentoo` :

```sh
export EPREFIX=/usr/local/gentoo
```

```sh
# Choose the correct installation path and user:group permissions
docker build \
	--build-arg uid=1611 \
	--build-arg user=marc \
	--build-arg gid=1600 \
	--build-arg group=cluster-users \
	--build-arg eprefix=$EPREFIX \
	-t gentoo-builder .
```

## Mkdir + chown output

```sh
mkdir -p $EPREFIX
sudo chown 1611:1600 $EPREFIX
```

## Run script

```sh
# The volume binding names must match
docker run -it --rm --name gentoo-builder \
	-v $EPREFIX:$EPREFIX \
	gentoo-builder
```

```txt
Do you want me to start off now? [Yn]
How many parallel make jobs do you want? [8] 48
Do you want to use stable Prefix? [Yn]
What do you want EPREFIX to be? [/usr/local/gentoo]
Type here what you want to wish me [luck]
```

## Fix the circulardependency and pwd

### Ignore the runtime dependency `sys-libs/libxcrypt`

The script will crash at the first circular dependency.

```txt
 * Error: circular dependencies:

(virtual/libcrypt-2:0/2::gentoo, ebuild scheduled for merge) depends on
 (sys-libs/libxcrypt-4.4.26:0/1::gentoo, ebuild scheduled for merge) (runtime)
  (dev-lang/perl-5.34.0-r5:0/5.34::gentoo, ebuild scheduled for merge) (buildtime)
   (virtual/libcrypt-2:0/2::gentoo, ebuild scheduled for merge) (buildtime_slot_op)

 * Note that circular dependencies can often be avoided by temporarily
 * disabling USE flags that trigger optional dependencies.
```

We will fix this circular dependency in addition to the non-detection of `libperl.so`.

```sh
mkdir -p $EPREFIX/tmp/etc/portage/profile/
echo "sys-libs/libxcrypt-4.4.26" >> $EPREFIX/tmp/etc/portage/profile/package.provided
```

This allows to ignore the `sys-libs/libxcrypt-4.4.26` dependency which is a runtime dependency.

### Detect libperl.so

Edit `$EPREFIX/etc/portage/make.conf` and add :

```sh
LD_LIBRARY_PATH="/usr/local/gentoo/usr/lib64:/usr/local/gentoo/usr/lib:/usr/local/gentoo/tmp/lib64:/usr/local/gentoo/tmp/lib:/usr/local/gentoo/tmp/usr/lib64:/usr/local/gentoo/tmp/usr/lib"
```

Replace `/usr/local/gentoo` with the value of `$EPREFIX`.

### Put pwd

```sh
cp /bin/pwd $EPREFIX/tmp/bin/pwd
```

### Run again

Run again :

```sh
docker run -it --rm --name gentoo-builder \
	-v $EPREFIX:$EPREFIX \
	gentoo-builder
```

If it crashes at some point, remove `$EPREFIX/tmp/etc/portage/profile/package.provided`.

Restart the script with the same parameters.
