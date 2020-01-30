#!/bin/bash

set -euo pipefail

ulimit -v 33554432

find Data -name '*.laz' -print | \
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
		AVG_PT_SPACING=$(jq '.stages["filters.hexbin"][0].avg_pt_spacing' "${res_bn}.metadata.json")
		AVG_GND_SPACING=$(jq '.stages["filters.hexbin"][1].avg_pt_spacing' "${res_bn}.metadata.json")

		echo Point Spacing: $AVG_PT_SPACING Ground Point Spacing: $AVG_GND_SPACING

		if [[ $AVG_GND_SPACING > 3 ]] ; then
			RESOLUTION=10
			RADIUS=14.14
			RADIUS2=28.08
		elif [[ $AVG_GND_SPACING > 0.5 ]] ; then
			RESOLUTION=3
			RADIUS=4.24
			RADIUS2=8.48
		elif [[ $AVG_GND_SPACING > 0 ]] ; then
			RESOLUTION=0.5
			RADIUS=0.707
			RADIUS2=1.414
		else
			echo "Ground points not classified in src ${src_name}"
			continue
		fi

		#pdal pipeline reclassify.py.pipeline.json \
		#	--readers.las.filename="${src_name}" \
		#	--writers.las.filename="${res_bn}".reclass.laz &

		echo Using resolution: "${RESOLUTION}"		

		pdal pipeline dsm2.pipeline.json \
			--readers.las.filename="${src_name}" \
			--writers.gdal.resolution=${RESOLUTION} \
			--writers.gdal.radius=${RADIUS2} \
			--writers.gdal.output_type=idw \
			--writers.gdal.filename="${res_bn}".dsm.temp.tif &
		pdal pipeline dem.pipeline.json \
			--readers.las.filename="${src_name}" \
			--writers.gdal.resolution=${RESOLUTION} \
			--writers.gdal.radius=${RADIUS} \
			--writers.gdal.output_type=idw \
			--writers.gdal.filename="${res_bn}".dem.temp.tif &
		wait
		rm -f "${res_bn}".spikefree.tif
		gdalwarp -r near -srcnodata -9999 -dstnodata -9999 \
			"${res_bn}".dem.temp.tif \
			"${res_bn}".dsm.temp.tif \
			"${res_bn}".spikefree.tif

		exit
	done

