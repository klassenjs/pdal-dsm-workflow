#!/bin/bash

set -euo pipefail

ulimit -v 33554432

find ../Data/BoisNoir_2009_opendata -name '*.laz' -print | \
	while read src_name ; do
		res_bn="${src_name/Data/results}"
		res_bn="${res_bn%.laz}"
		res_dir="$(dirname $res_bn)"
		#echo $src_name $res_bn $res_dir

		echo $src_name $(date)

		mkdir -p "${res_dir}"

		pdal pipeline reclassify.py.pipeline.json \
			--readers.las.filename="${src_name}" \
			--writers.las.filename="${res_bn}".reclass.laz
	done

