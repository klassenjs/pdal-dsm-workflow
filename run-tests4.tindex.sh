#!/bin/bash

set -euo pipefail

ulimit -v 33554432

	while read src_name bounds_o bounds_i; do
		#echo $src_name ... $bounds

		res_bn="${src_name/Data/results}"
		res_bn="${res_bn%.laz}"
		res_dir="$(dirname $res_bn)"
		#echo $src_name $res_bn $res_dir

		echo $src_name $(date)

		mkdir -p "${res_dir}"

		#pdal pipeline hexbin.pipeline.json \
		#	--readers.las.filename="${src_name}" \
		#	--metadata "${res_bn}.metadata.json"
		#AVG_PT_SPACING=$(jq '.stages["filters.hexbin"][0].avg_pt_spacing' "${res_bn}.metadata.json")
		#AVG_GND_SPACING=$(jq '.stages["filters.hexbin"][1].avg_pt_spacing' "${res_bn}.metadata.json")

		#echo Point Spacing: $AVG_PT_SPACING Ground Point Spacing: $AVG_GND_SPACING

		RESOLUTION=3

		echo Using resolution: "${RESOLUTION}"
		
		touch "${res_bn}".start

		#strace -e trace=open \
		pdal pipeline all.tindex.pipeline.json \
			 --readers.tindex.bounds="${bounds_i}" \
			 --stage.ndsm_writer.resolution=${RESOLUTION} \
			 --stage.ndsm_writer.bounds="${bounds_o}" \
			 --stage.ndsm_writer.filename="${res_bn}".ndsm.tif \
			 --stage.dsm_writer.resolution=${RESOLUTION} \
			 --stage.dsm_writer.bounds="${bounds_o}" \
			 --stage.dsm_writer.filename="${res_bn}".dsm.tif \
			 --stage.dem_writer.resolution=${RESOLUTION} \
			 --stage.dem_writer.bounds="${bounds_o}" \
			 --stage.dem_writer.filename="${res_bn}".dem.tif \
			 --stage.agl_writer.filename="${res_bn}".agl.laz \

		touch "${res_bn}".done

	done <<EOF
# North of Duluth about 30s each, (1 sqkm)
./Data/15TWN3030.tdx	([530000,531000],[5230000,5231000])	([529900,531100],[5229900,5231100])
./Data/15TWN3031.tdx	([530000,531000],[5231000,5232000])	([529900,531100],[5230900,5232100])
./Data/15TWN3032.tdx	([530000,531000],[5232000,5233000])	([529900,531100],[5231900,5233100])
./Data/15TWN3033.tdx	([530000,531000],[5233000,5234000])	([529900,531100],[5232900,5234100])
./Data/15TWN3130.tdx	([531000,532000],[5230000,5231000])	([530900,532100],[5229900,5231100])
./Data/15TWN3131.tdx	([531000,532000],[5231000,5232000])	([530900,532100],[5230900,5232100])
./Data/15TWN3132.tdx	([531000,532000],[5232000,5233000])	([530900,532100],[5231900,5233100])
./Data/15TWN3133.tdx	([531000,532000],[5233000,5234000])	([530900,532100],[5232900,5234100])
EOF

	# TODO: The main issue now is that th 3m pixel size doesn't fit a 1km or 10km tile.

other=<<EOF
./Data/15TWN59622957.tdx	([596251.5,597001.5],[5295751.5,5296501.5])
./Data/4342-01-27_a_d.tdx	([485202.13,486072.13],[4982095.1,4981477.1])
./Data/4342-08-28_b.tdx	([488855.82,490094.82],[4956920.36,4958657.36])

./Data/15TVL30.tdx	([430000,440000],[5000000,5010000])
./Data/15TVL31.tdx	([430000,440000],[5010000,5020000])
./Data/15TVK88.tdx	([480000,490000],[4980000,4990000])

# UMN St. Paul Campus - about 1m each (1 sqkm)
./Data/15TVK8080.tdx	([480000,481000],[4980000,4981000])
./Data/15TVK8180.tdx	([481000,482000],[4980000,4981000])
./Data/15TVK8280.tdx	([482000,483000],[4980000,4981000])
./Data/15TVK8380.tdx	([483000,484000],[4980000,4981000])
./Data/15TVK8480.tdx	([484000,485000],[4980000,4981000])
./Data/15TVK8580.tdx	([485000,486000],[4980000,4981000])
./Data/15TVK8680.tdx	([486000,487000],[4980000,4981000])
./Data/15TVK8780.tdx	([487000,488000],[4980000,4981000])
./Data/15TVK8880.tdx	([488000,489000],[4980000,4981000])
./Data/15TVK8980.tdx	([489000,490000],[4980000,4981000])

./Data/15TVK8081.tdx	([480000,481000],[4981000,4982000])
./Data/15TVK8181.tdx	([481000,482000],[4981000,4982000])
./Data/15TVK8281.tdx	([482000,483000],[4981000,4982000])
./Data/15TVK8381.tdx	([483000,484000],[4981000,4982000])
./Data/15TVK8481.tdx	([484000,485000],[4981000,4982000])
./Data/15TVK8581.tdx	([485000,486000],[4981000,4982000])
./Data/15TVK8681.tdx	([486000,487000],[4981000,4982000])
./Data/15TVK8781.tdx	([487000,488000],[4981000,4982000])
./Data/15TVK8881.tdx	([488000,489000],[4981000,4982000])
./Data/15TVK8981.tdx	([489000,490000],[4981000,4982000])

# North of Duluth about 10m each, (10 sqkm)
./Data/15TWN33.tdx	([530000,540000],[5230000,5240000])	([529900,540100],[5229900,5240100]) 
./Data/15TWN34.tdx	([530000,540000],[5240000,5250000])	([529900,540100],[5239900,5250100])
./Data/15TWN43.tdx	([540000,550000],[5230000,5240000])	([539900,550100],[5229900,5240100])
./Data/15TWN44.tdx	([540000,550000],[5240000,5250000])	([539900,550100],[5239900,5250100])

EOF
