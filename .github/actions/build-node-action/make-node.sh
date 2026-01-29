#!/bin/sh

set -e
set -x

NODE_VERSION=$1

NODE_DIR=node-${NODE_VERSION}
NODE_TARBALL=node-${NODE_VERSION}.tar.gz

cd ${GITHUB_WORKSPACE}
curl https://nodejs.org/dist/${NODE_VERSION}/${NODE_TARBALL} > ${NODE_TARBALL}
tar xzf ${NODE_TARBALL}
cd ${NODE_DIR}

# These flags are required for CentOS 6, and are the whole
# reason for doing our own builds
export CPPFLAGS=-D__STDC_FORMAT_MACROS
export LDFLAGS=-lrt

scl enable devtoolset-9 rh-python36 "./configure --fully-static --enable-static"
scl enable devtoolset-9 rh-python36 "ARCH=x64 make -j$(nproc) binary"

cd ${GITHUB_WORKSPACE}

mkdir centos_patch
cd centos_patch

wget https://github.com/NixOS/patchelf/releases/download/0.14.5/patchelf-0.14.5-x86_64.tar.gz
## this unpacks in the current folder
tar -xvzf patchelf-0.14.5-x86_64.tar.gz

tar -xvzf ${GITHUB_WORKSPACE}/${NODE_DIR}/node-${NODE_VERSION}-linux-x64.tar.gz

cd node-${NODE_VERSION}-linux-x64
cp -R /lib64 ./lib64

# Ensure we don't accidentally pick up the host's libstdc++/libgcc_s at runtime.
# These come from devtoolset-9 (built for EL6) and should be more compatible than
# whatever happens to be installed on the target system (e.g. Rocky).
LIBSTDCXX_PATH=$(scl enable devtoolset-9 "g++ -print-file-name=libstdc++.so.6")
LIBGCC_PATH=$(scl enable devtoolset-9 "gcc -print-file-name=libgcc_s.so.1")

cp -L "${LIBSTDCXX_PATH}" ./lib64/
cp -L "${LIBGCC_PATH}" ./lib64/

# Optional but commonly needed with modern toolchains.
LIBATOMIC_PATH=$(scl enable devtoolset-9 "gcc -print-file-name=libatomic.so.1")
if [ -f "${LIBATOMIC_PATH}" ] && [ "${LIBATOMIC_PATH}" != "libatomic.so.1" ]; then
	cp -L "${LIBATOMIC_PATH}" ./lib64/
fi

LIBGOMP_PATH=$(scl enable devtoolset-9 "gcc -print-file-name=libgomp.so.1")
if [ -f "${LIBGOMP_PATH}" ] && [ "${LIBGOMP_PATH}" != "libgomp.so.1" ]; then
	cp -L "${LIBGOMP_PATH}" ./lib64/
fi

cd bin
../../bin/patchelf --set-interpreter ../lib64/ld-linux-x86-64.so.2 --set-rpath '$ORIGIN/../lib64' node 

## now repack
cd ${GITHUB_WORKSPACE}/centos_patch
tar -cf node-${NODE_VERSION}-linux-x64.tar node-${NODE_VERSION}-linux-x64
rm -f -r node-${NODE_VERSION}-linux-x64
gzip -c -f -9 node-${NODE_VERSION}-linux-x64.tar > node-${NODE_VERSION}-linux-x64.tar.gz
xz -c -f -9e node-${NODE_VERSION}-linux-x64.tar > node-${NODE_VERSION}-linux-x64.tar.xz
rm -f node-${NODE_VERSION}-linux-x64.tar
sha256sum node-${NODE_VERSION}-linux-x64.tar.xz node-${NODE_VERSION}-linux-x64.tar.gz > SHASUMS256.txt
