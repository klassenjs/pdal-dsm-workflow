#!/bin/bash 
#SBATCH -w rambler
#SBATCH -c 8
#SBATCH --mem=0

#ulimit -v 40960000

find .. -name '*.ndsm.tif' > ndsm.lst
gdalbuildvrt -input_file_list ndsm.lst ndsm.vrt
gdaladdo -r average ndsm.vrt 4 16 64 256 &


find .. -name '*.dem.tif' > dem.lst
gdalbuildvrt -input_file_list dem.lst dem.vrt
gdaladdo -r average dem.vrt 4 16 64 256 &


find .. -name '*.dsm.tif' > dsm.lst
gdalbuildvrt -input_file_list dsm.lst dsm.vrt
gdaladdo -r average dsm.vrt 4 16 64 256

wait

gdal_translate -co BIGTIFF=YES -co COPY_SRC_OVERVIEWS=YES -co TILED=YES -co BLOCKXSIZE=512 -co BLOCKYSIZE=512 -co COMPRESS=LZW -co NUM_THREADS=8 ndsm.vrt ndsm.tif &
gdal_translate -co BIGTIFF=YES -co COPY_SRC_OVERVIEWS=YES -co TILED=YES -co BLOCKXSIZE=512 -co BLOCKYSIZE=512 -co COMPRESS=LZW -co NUM_THREADS=8 dem.vrt dem.tif &
gdal_translate -co BIGTIFF=YES -co COPY_SRC_OVERVIEWS=YES -co TILED=YES -co BLOCKXSIZE=512 -co BLOCKYSIZE=512 -co COMPRESS=LZW -co NUM_THREADS=8 dsm.vrt dsm.tif &
wait

