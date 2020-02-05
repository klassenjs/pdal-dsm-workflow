ulimit -v 40960000

find .. -name '*.dsm.tif' > dsm.lst
gdalbuildvrt -b 2 -input_file_list dsm.lst dsm_count.vrt
gdalwarp -co TILED=YES -co BIGTIFF=YES -co BLOCKXSIZE=1008 -co BLOCKYSIZE=1008 dsm_count.vrt dsm_count.tif
gdaladdo -r average dsm_count.tif 2 4 8 16 32 64 128 256 512 1024

