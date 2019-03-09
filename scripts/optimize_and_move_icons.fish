#!/usr/bin/env fish

set -l ICONDIR $argv[1]
set -l PROJECTDIR $argv[2]
set -l CURRENTDIR (pwd)

echo "Optimizing icons to $ICONDIR/crushed"

cd $ICONDIR
pngquant --speed 1 *.png
mkdir -p $ICONDIR/crushed
mv *-fs8.png $ICONDIR/crushed
rename -X -s '-fs8' '' $ICONDIR/crushed/*.png
cd $ICONDIR/crushed

echo "Moving icons to their folders inside $PROJECTDIR"

for file in *.png
    set iconType (string match -r '^(.+)-(?:apple|android|favicon).+' $file)
    mkdir -p $PROJECTDIR/static/img/icons/$iconType[2]
    mv $file $PROJECTDIR/static/img/icons/$iconType[2]/
end

cd $CURRENTDIR
