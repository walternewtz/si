#sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/LineageOS/android -b lineage-19.1 -g default,-mips,-darwin,-notdefault
git clone https://github.com/greengreen2212/local_manifest.git --depth 1 -b lin1 .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j10

#build 
source build/envsetup.sh
lunch lineage_beryllium-userdebug
export TZ=Asia/Delhi
export BUILD_USERNAME=beryllium
export BUILD_HOSTNAME=userdebug
export SKIP_ABI_CHECKS=true
export SKIP_BOOTJAR_CHECKS=true
export _JAVA_OPTIONS="-Xmx12g"

make bacon -j30 &
sleep 75m
kill %1

# upload rom
rclone copy out/target/product/$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)/*.zip cirrus:$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1) -P