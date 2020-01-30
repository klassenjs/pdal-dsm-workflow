#!/bin/bash

set -euo pipefail

ulimit -v 33554432

	while read src_name bounds ; do
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

		pdal pipeline all.ept.pipeline.json \
			 --readers.ept.bounds="${bounds}" \
			 --stage.ndsm_writer.resolution=${RESOLUTION} \
			 --stage.ndsm_writer.filename="${res_bn}".ndsm.tif \
			 --stage.dsm_writer.resolution=${RESOLUTION} \
			 --stage.dsm_writer.filename="${res_bn}".dsm.tif \
			 --stage.dem_writer.resolution=${RESOLUTION} \
			 --stage.dem_writer.filename="${res_bn}".dem.tif \
			 --stage.agl_writer.filename="${res_bn}".agl.laz \

	done <<EOF
./Data/4342-01-27_a_d.ept	([-10373610.44,-10372740.05],[5619055.872,5620287.159])
./Data/4342-08-28_b.ept	([-10368393.23,-10366646.2],[5584694.714,5587148.173])
EOF
# ./Data/15TWN59622957.ept	([-10209605,-10208470],[6074937,6076076])
