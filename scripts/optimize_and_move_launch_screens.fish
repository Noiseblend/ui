#!/usr/bin/env fish

set -l ICONDIR $argv[1]
set -l PROJECTDIR $argv[2]
set -l CURRENTDIR (pwd)

echo "Optimizing launch screens to $ICONDIR/crushed"

cd $ICONDIR
pngquant --speed 1 *.png
mkdir -p $ICONDIR/crushed
mv *-fs8.png $ICONDIR/crushed
rename -X -s '-fs8' '' $ICONDIR/crushed/*.png
cd $ICONDIR/crushed

echo "Moving launch screens to their folders inside $PROJECTDIR"

for file in *.png
    set iconType (string match -r '^(.+)-apple-launch-.+' $file)
    mkdir -p $PROJECTDIR/static/img/launch-screens/$iconType[2]
    mv $file $PROJECTDIR/static/img/launch-screens/$iconType[2]/
end

cd $CURRENTDIR
