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

		#strace -e trace=open \
		pdal pipeline all.tindex.pipeline.json \
			 --readers.tindex.bounds="${bounds}" \
			 --stage.ndsm_writer.resolution=${RESOLUTION} \
			 --stage.ndsm_writer.filename="${res_bn}".ndsm.tif \
			 --stage.dsm_writer.resolution=${RESOLUTION} \
			 --stage.dsm_writer.filename="${res_bn}".dsm.tif \
			 --stage.dem_writer.resolution=${RESOLUTION} \
			 --stage.dem_writer.filename="${res_bn}".dem.tif \
			 --stage.agl_writer.filename="${res_bn}".agl.laz \

	done <<EOF
./Data/15TWN59622957.tdx	([596251.5,597001.5],[5295751.5,5296501.5])
./Data/4342-01-27_a_d.tdx	([485202.13,486072.13],[4982095.1,4981477.1])
./Data/4342-08-28_b.tdx	([488855.82,490094.82],[4956920.36,4958657.36])
EOF

