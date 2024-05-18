FROM alpine:3.17.6

# 指定command环境变量
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 指定 LANG
ENV LANG=C.UTF-8

# 安装依赖环境
RUN /bin/sh -c set -eux; apk add --no-cache gpg dpkg dpkg-dev make gcc gdbm-dev libc-dev libffi-dev libnsl-dev libtirpc-dev linux-headers ncurses-dev openssl-dev pax-utils readline-dev sqlite-dev tcl-dev tk tk-dev util-linux-dev zlib-dev

# 指定Python密钥
ENV GPG_KEY=A035C8C19219BA821ECEA86B64E628F8D684696D

# 指定python版本
ENV PYTHON_VERSION=3.11.3

# 编译python版本
RUN /bin/sh -c set -eux; wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"; wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc"; GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$GPG_KEY"; gpg --batch --verify python.tar.xz.asc python.tar.xz; gpgconf --kill all; rm -rf "$GNUPGHOME" python.tar.xz.asc; mkdir -p /usr/src/python; tar --extract --directory /usr/src/python --strip-components=1 --file python.tar.xz; rm python.tar.xz; cd /usr/src/python; gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; ./configure --build="$gnuArch" --enable-loadable-sqlite-extensions --enable-optimizations --enable-option-checking=fatal --enable-shared --with-lto --with-system-expat --without-ensurepip ; nproc="$(nproc)"; EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)"; LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; make -j "$nproc" "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" "LDFLAGS=${LDFLAGS:-}" "PROFILE_TASK=${PROFILE_TASK:-}" ; rm python; make -j "$nproc" "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" "LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" "PROFILE_TASK=${PROFILE_TASK:-}" python ; make install; bin="$(readlink -ve /usr/local/bin/python3)"; dir="$(dirname "$bin")"; mkdir -p "/usr/share/gdb/auto-load/$dir"; cp -vL Tools/gdb/libpython.py "/usr/share/gdb/auto-load/$bin-gdb.py"; cd /; rm -rf /usr/src/python; find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \) -exec rm -rf '{}' + ; ldconfig; python3 --version # buildkit

# 指定python pip version
ENV PYTHON_PIP_VERSION=22.3.1

# 指定python SETUPTOOLS VERSION
ENV PYTHON_SETUPTOOLS_VERSION=65.5.1

# python pip download url
ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/dbf0c85f76fb6e1ab42aa672ffca6f0a675d9ee4/public/get-pip.py

# pip file sha256 value
ENV PYTHON_GET_PIP_SHA256=dfe9fd5c28dc98b5ac17979a953ea550cec37ae1b47a5116007395bfacff2ab9

# 下载pip文件并安装pip
RUN /bin/sh -c set -eux; wget -O get-pip.py "$PYTHON_GET_PIP_URL"; echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum -c -; export PYTHONDONTWRITEBYTECODE=1; python3 get-pip.py --disable-pip-version-check --no-cache-dir --no-compile "pip==$PYTHON_PIP_VERSION" "setuptools==$PYTHON_SETUPTOOLS_VERSION" && rm -f get-pip.py; pip --version

CMD ["python3"]

# ansible 版本
ENV ANSIBLE_VERSION=2.14.3

# 安装ansible
RUN /bin/sh -c set -eux; pip install pip --upgrade && pip install --no-cache-dir --user ansible-core==$ANSIBLE_VERSION ansible&& cp /root/.local/bin/* /usr/local/bin/ && rm -rf /var/cache/apk/*  && rm -rf /root/.cache 

ENV TZ=Asia/Shanghai

# 指定ocxzlab主程序版本
ENV VAGRANT_VERSION=2.5.10

RUN /bin/sh -c set -eux; wget -O vagrant.tar.gz "https://github.com/xxzjyyds/vagrant/releases/download/$VAGRANT_VERSION/vagrant_linux-$VAGRANT_VERSION.tar.gz"; tar zxf ./vagrant.tar.gz; mv vagrant /etc/vagrant && rm -rf ./vagrant.tar.gz # buildkit
