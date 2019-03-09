#!/usr/bin/env fish

rename -X -e '$_ = $N' *.jpg
mkdir -p thumbnails
for size in 8120 5260 3840 2560 1920 1280 992 768 320 64
    vipsthumbnail *.jpg --vips-progress --linear --size=$size --vips-concurrency=4 -o thumbnails/bg_%s_$size.jpg[optimize_coding,strip] --eprofile='/System/Library/ColorSync/Profiles/sRGB Profile.icc' --delete --rotate
end
vipsthumbnail *.jpg --vips-progress --linear --smartcrop=attention --size=64x64 --vips-concurrency=4 -o thumbnails/bg_%s_64.jpg[optimize_coding,strip] --eprofile='/System/Library/ColorSync/Profiles/sRGB Profile.icc' --delete --rotate

jpegoptim -s -t -m75 thumbnails/*.jpg

for f in *.jpg
    sqip -o (string replace -r 'jpg$' 'svg' $f) $f
end
