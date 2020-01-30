#!/bin/bash

set -euo pipefail

ulimit -v 33554432

find ./Data -name '*.laz' -print | \
	while read src_name ; do
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

		pdal pipeline all.pipeline.json \
			 --readers.las.filename="${src_name}" \
			 --stage.ndsm_writer.resolution=${RESOLUTION} \
			 --stage.ndsm_writer.filename="${res_bn}".ndsm.tif \
			 --stage.dsm_writer.resolution=${RESOLUTION} \
			 --stage.dsm_writer.filename="${res_bn}".dsm.tif \
			 --stage.dem_writer.resolution=${RESOLUTION} \
			 --stage.dem_writer.filename="${res_bn}".dem.tif \
			 --stage.agl_writer.filename="${res_bn}".agl.laz \

	done
