#!/bin/bash 
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=0

GDAL=../apps/gdal/v3.0.1-1-ged81e3e326
PATH="${GDAL}"/bin:$PATH
export PYTHONPATH="${GDAL}"/lib/python3/dist-packages
export LD_LIBRARY_PATH="${GDAL}"/lib

MYPATH="$(dirname "$0")"

echo $(date) Building VRT and OVR

find ../tiles -name '*.ndsm.tif' > ndsm.lst && \
	gdalbuildvrt -input_file_list ndsm.lst ndsm.vrt && \
	gdaladdo -r average ndsm.vrt 4 16 64 256 &


find ../tiles -name '*.dem.tif' > dem.lst && \
	gdalbuildvrt -input_file_list dem.lst dem.vrt && \
	gdaladdo -r average dem.vrt 4 16 64 256 &


find ../tiles -name '*.dsm.tif' > dsm.lst && \
	gdalbuildvrt -input_file_list dsm.lst dsm.vrt && \
	gdaladdo -r average dsm.vrt 4 16 64 256

wait


$MYPATH/setnames.py ndsm.vrt "ndsm (m)" "point count" "stddev point Z"
$MYPATH/setnames.py dem.vrt "dem (m)" "point count" "stddev point Z"
$MYPATH/setnames.py dsm.vrt "dsm (m)" "point count" "stddev point Z"

echo $(date) Building GeoTIFFs

gdal_translate -co BIGTIFF=YES -co COPY_SRC_OVERVIEWS=YES -co TILED=YES -co BLOCKXSIZE=512 -co BLOCKYSIZE=512 -co COMPRESS=LZW -co NUM_THREADS=8 ndsm.vrt ndsm.tif &
gdal_translate -co BIGTIFF=YES -co COPY_SRC_OVERVIEWS=YES -co TILED=YES -co BLOCKXSIZE=512 -co BLOCKYSIZE=512 -co COMPRESS=LZW -co NUM_THREADS=8 dem.vrt dem.tif &
gdal_translate -co BIGTIFF=YES -co COPY_SRC_OVERVIEWS=YES -co TILED=YES -co BLOCKXSIZE=512 -co BLOCKYSIZE=512 -co COMPRESS=LZW -co NUM_THREADS=8 dsm.vrt dsm.tif
wait

echo $(date) Done.
