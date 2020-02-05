#ulimit -v 40960000

find .. -name '*.ndsm.tif' > ndsm.lst
gdalbuildvrt -input_file_list ndsm.lst ndsm.vrt
gdalwarp -multi -wm 8192 -wo NUM_THREADS=8 -co TILED=YES -co BIGTIFF=YES -co BLOCKXSIZE=1008 -co BLOCKYSIZE=1008 ndsm.vrt ndsm.tif
gdaladdo -r average ndsm.tif 2 4 8 16 32 64 128 256 512 1024 &

find .. -name '*.dem.tif' > dem.lst
gdalbuildvrt -input_file_list dem.lst dem.vrt
#gdalwarp -multi -wm 8192 -wo NUM_THREADS=8 -co TILED=YES -co BIGTIFF=YES -co BLOCKXSIZE=1008 -co BLOCKYSIZE=1008 dem.vrt dem.tif
gdaladdo -r average dem.vrt 2 4 8 16 32 64 128 256


find .. -name '*.dsm.tif' > dsm.lst
gdalbuildvrt -input_file_list dsm.lst dsm.vrt
#gdalwarp -multi -wm 8192 -wo NUM_THREADS=8 -co TILED=YES -co BIGTIFF=YES -co BLOCKXSIZE=1008 -co BLOCKYSIZE=1008 dsm.vrt dsm.tif
gdaladdo -r average dsm.vrt 2 4 8 16 32 64 128 256
