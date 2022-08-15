FROM ubuntu:21.10
CMD ["bash"]
LABEL maintainer=walternewtz
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C
ENV CIRRUS_CPU=24
ENV USE_CCACHE=1
#ENV ANDROID_JACK_VM_ARGS=-Dfile.encoding=UTF-8 
#ENV ANDROID_JACK_VM_ARGS=-XX:+TieredCompilation 
ENV CCACHE_EXEC=/usr/bin/ccache
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /tmp

RUN apt-get -yqq update \  
    && apt-get install --no-install-recommends -yqq adb cloud-guest-utils iproute2 libxml2-dev libxslt1-dev libmemcached-dev awscli libgd-dev libzip-dev asciidoctor docbook-xml docbook-xsl elfutils bash libhiredis-dev redis-server redis-tools sudo tzdata locales python-is-python3 python3-pip pigz tar rsync rclone aria2 ccache curl wget zip unzip lzip lzop zlib1g-dev xzdec xz-utils pixz p7zip-full p7zip-rar zstd libzstd-dev lib32z1-dev ffmpeg maven nodejs ca-certificates-java pigz tar rsync rclone aria2 libncurses5 adb autoconf automake axel bc bison build-essential ccache clang cmake brotli curl expat fastboot flex g++ g++-multilib gawk gcc gcc-multilib git gnupg gperf htop imagemagick locales libncurses5 lib32ncurses5-dev lib32z1-dev libtinfo5 libc6-dev libcap-dev libexpat1-dev libgmp-dev '^liblz4-.*' '^liblzma.*' libmpc-dev libmpfr-dev libncurses5-dev libsdl1.2-dev libssl-dev libtool libxml-simple-perl libxml2 libxml2-utils lsb-core lzip '^lzma.*' lzop maven nano ncftp ncurses-dev openssh-server openssh-client sshpass patch patchelf pkg-config pngcrush pngquant python2.7 python-all-dev re2c rclone rsync schedtool squashfs-tools subversion sudo tar texinfo tmate tzdata unzip w3m wget xsltproc zip zlib1g-dev zram-config zstd axel flex bison ncurses-dev texinfo gcc gperf patch libtool automake g++ libncurses5-dev gawk subversion expat libexpat1-dev python-all-dev binutils-dev bc libcap-dev autoconf libgmp-dev build-essential pkg-config libmpc-dev libmpfr-dev autopoint gettext txt2man liblzma-dev libssl-dev libz-dev mercurial wget tar gcc-10 g++-10 cmake ninja-build zstd lz4 liblz4-tool liblz4-dev lzma openjdk-17* golang-go lsb-release wget software-properties-common docker.io --fix-broken --fix-missing \ 
    && apt-get -yqq upgrade libstdc++6 \
    && apt-get -yqq dist-upgrade \
    && curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo \ 
    && chmod a+rx /usr/local/bin/repo \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \ 
    && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && /usr/sbin/locale-gen && TZ=Asia/Kolkata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN git config --global user.name greengreen2212 && git config --global user.email greenhumam@protonmail.com

RUN apt-get install tzdata && apt-mark hold tzdata && ln -snf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && echo Asia/Kolkota > /etc/timezone

RUN python3 -m pip  install networkx && ln -sf /usr/bin/python3 /usr/bin/python 

RUN git clone --depth 1 https://github.com/CyberJalagam/android_rom_building_scripts scripts && bash scripts/build.sh 

RUN git clone --depth 1 https://github.com/mirror/make $WORKDIR/make && cd $WORKDIR/make && ./bootstrap && ./configure && make CFLAGS="-O3" && sudo install ./make /usr/bin/make 

RUN wget https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.2.2.tar.gz && tar xzf libwebp-1.2.2.tar.gz && cd libwebp-1.2.2 && export PATH="/usr/lib/ccache:$PATH" && which clang && ./configure && make -j$(nproc --all) 

RUN git clone --depth 1 https://github.com/ninja-build/ninja.git $WORKDIR/ninja && cd $WORKDIR/ninja && ./configure.py --bootstrap && sudo install ./ninja /usr/bin/ninja

RUN git clone --depth 1 https://github.com/google/kati.git $WORKDIR/kati && cd $WORKDIR/kati && make ckati && sudo install ./ckati /usr/bin/ckati 

RUN axel -a -n 10 https://github.com/facebook/zstd/releases/download/v1.5.0/zstd-1.5.0.tar.gz && tar xvzf zstd-1.5.0.tar.gz && cd zstd-1.5.0 && sudo make install 

RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip && unzip rclone-current-linux-amd64.zip && cd rclone-*-linux-amd64 && sudo cp rclone /usr/bin/ && sudo chown root:root /usr/bin/rclone && sudo chmod 755 /usr/bin/rclone 

RUN git clone --depth 1 https://github.com/TheLartians/Ccache.cmake $WORKDIR/Ccache.cmake && cd $WORKDIR/Ccache.cmake && cmake -Htest -Bbuild -DUSE_CCACHE=YES -DCCACHE_OPTIONS="CCACHE_CPP2=true;CCACHE_SLOPPINESS=clang_index_store" && cmake --build build && cmake -Htest -Bbuildx -GNinja -DUSE_CCACHE=YES -DCCACHE_OPTIONS="CCACHE_CPP2=true;CCACHE_SLOPPINESS=clang_index_store" && cmake --build buildx

RUN rm -rf /var/lib/dpkg/info/*.postinst && dpkg --configure -a && rm -rf libwebp-1.2.2.tar.gz && rm -rf rclone-current-linux-amd64.zip && rm -rf zstd-1.5.0.tar.gz && rm -rf * && rm -rf /var/lib/apt/lists/* 

WORKDIR /tmp

VOLUME [/tmp/rom /tmp/ccache]

ENTRYPOINT ["/bin/bash"]
