#!/bin/sh

set -o errexit
set -o nounset

#set -o pipefail
set -x

REVISION=17.0.7_p7-r1
URL=http://dl-cdn.alpinelinux.org/alpine/edge/community/
ARCH="aarch64 ppc64le s390x x86_64"
PACKAGES="openjdk17 openjdk17-jdk openjdk17-jre openjdk17-jre-headless"

old_pwd=$(pwd)
tmp_dir=$(mktemp -d -t openjdk17-XXXXXXXXXX)
trap "rm -rf $tmp_dir" EXIT

cd "${tmp_dir}"

#download packages
for arch in $ARCH;do
	for package in $PACKAGES; do
		curl -o "${package}-${REVISION}_${arch}.apk" "${URL}/${arch}/${package}-${REVISION}.apk"
	done
done 

#mkdir
for arch in $ARCH;do
	mkdir "openjdk17-${arch}"
done

#extract apks to corresponding arch dir
for arch in $ARCH;do
	for package in $PACKAGES; do
		tar xzf "${package}-${REVISION}_${arch}.apk" -C "openjdk17-${arch}"
	done
done

for arch in $ARCH;do
	chmod +x "openjdk17-${arch}/usr/lib/jvm/java-17-openjdk/bin/" 
done

#tar them up agains
for arch in $ARCH;do
	tar czf "openjdk-17_${arch}.tar.gz" -C "openjdk17-${arch}/usr/lib/jvm/java-17-openjdk/" .
done



cd "${old_pwd}"

for arch in $ARCH;do
	cp "$tmp_dir/openjdk-17_${arch}.tar.gz" "./"
done

