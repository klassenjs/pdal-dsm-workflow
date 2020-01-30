#!/bin/bash

set -euo pipefail

ulimit -v 33554432

find ../results/BoisNoir_2009_opendata -name '*.laz' -print | \
	while read src_name ; do
		res_bn="${src_name/Data/results}"
		res_bn="${res_bn%.laz}"
		res_dir="$(dirname $res_bn)"
		#echo $src_name $res_bn $res_dir

		echo $src_name $(date)

		mkdir -p "${res_dir}"

		pdal pipeline hexbin.pipeline.json \
			--readers.las.filename="${src_name}" \
			--metadata "${res_bn}.metadata.json"
		AVG_PT_SPACING=$(jq '.stages["filters.hexbin"][0].avg_pt_spacing' "${res_bn}.metadata.json")
		AVG_GND_SPACING=$(jq '.stages["filters.hexbin"][1].avg_pt_spacing' "${res_bn}.metadata.json")

		echo Point Spacing: $AVG_PT_SPACING Ground Point Spacing: $AVG_GND_SPACING

		# if [[ $AVG_PT_SPACING > 3 ]] ; then
		# 	RESOLUTION=10
		# 	RADIUS=14.14
		# 	RADIUS2=28.08
		# #elif [[ $AVG_PT_SPACING > 0.5 ]] ; then
		# #	RESOLUTION=3
		# #	RADIUS=4.24
		# #	RADIUS2=8.48
		# #elif [[ $AVG_PT_SPACING > 0.3 ]] ; then
		# #	RESOLUTION=0.5
		# #	RADIUS=0.707
		# #	RADIUS2=1.414
		# elif [[ $AVG_PT_SPACING > 0.3 ]] ; then
		# 	RESOLUTION=0.25
		# 	RADIUS=0.3535
		# 	RADIUS2=0.707
		# elif [[ $AVG_PT_SPACING > 0 ]] ; then
			RESOLUTION=0.15
			RADIUS=0.2121
			RADIUS2=0.4242
		# else
		# 	echo "Ground points not classified in src ${src_name}"
		# 	continue
		# fi

		#pdal pipeline reclassify.py.pipeline.json \
		#	--readers.las.filename="${src_name}" \
		#	--writers.las.filename="${res_bn}".reclass.laz &


		echo Using resolution: "${RESOLUTION}"		

		for m in mean max idw ; do
			for r in $RADIUS $RADIUS2 ; do
				echo $m $r
				pdal pipeline chm.pipeline.json \
					--readers.las.filename="${src_name}" \
					--writers.gdal.resolution=${RESOLUTION} \
					--writers.gdal.radius=$r \
					--writers.gdal.output_type=$m \
					--writers.gdal.filename="${res_bn}".hag-$m-$r.tif &
				pdal pipeline dsm.pipeline.json \
					--readers.las.filename="${src_name}" \
					--writers.gdal.resolution=${RESOLUTION} \
					--writers.gdal.radius=$r \
					--writers.gdal.output_type=$m \
					--writers.gdal.filename="${res_bn}".dsm-$m-$r.tif &
				pdal pipeline dem.pipeline.json \
					--readers.las.filename="${src_name}" \
					--writers.gdal.resolution=${RESOLUTION} \
					--writers.gdal.radius=$r \
					--writers.gdal.output_type=$m \
					--writers.gdal.filename="${res_bn}".dem-$m-$r.tif &
			done
		done
		wait

	done

