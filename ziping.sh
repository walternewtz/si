#!/bin/bash

msg() {
    echo -e "\e[1;32m$*\e[0m"
}

function enviroment() {
   device=$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
   name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
   JOS=$WORKDIR/rom/$name_rom/out/target/product/$device/
}

function upload_rom() {
   msg Uploading ROM ...
   rclone copy --drive-chunk-size 256M --include *.zip --stats 1s $JOS rom:rom/$name_rom -P
   msg ROM Uploaded Succesfully ...
}

function upload_ccache() {
   cd $WORKDIR
  com ()
   {
    tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
   }
   time com ccache 1
   rclone copy --drive-chunk-size 256M --stats 1s ccache.tar.gz rom:rom/ccache/$name_rom -P
   rm -rf ccache.tar.gz
   msg Cache Uploaded Succesfully ...
}

function upload() {
   enviroment
   if ! [ -a "$JOS" ]; then
     msg Uploading Cache ...
     upload_ccache
   fi
   upload_rom
}

upload
