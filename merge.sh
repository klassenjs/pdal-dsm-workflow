#!/bin/bash

set -u

ulimit -v 6291456

WARPOPTS="-multi -co COMPRESS=LZW -co TILED=YES -co INTERLEAVE=BAND"

for x in `seq 1 7` ; do
	for y in `seq 48 54` ; do
    echo $x $y
		gdalwarp $WARPOPTS ${x}?????_${y}?????.dem.tif merged/${x}_${y}.dem.tif
		gdalwarp $WARPOPTS ${x}?????_${y}?????.dsm.tif merged/${x}_${y}.dsm.tif
		gdalwarp $WARPOPTS ${x}?????_${y}?????.ndsm.tif merged/${x}_${y}.ndsm.tif
	done
done
