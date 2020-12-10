#!/bin/bash

set -euo pipefail

src_name="$1"
res_bn="$2"
bounds_i="$3"
bounds_or="$4"
bounds_ol="$5"
RESOLUTION="$6"

if [ ! -d "$(dirname "${res_bn}")" ] ; then
	echo "Output directory missing: $(dirname "${res_bn}")"
elif [ -f "${res_bn}".done ] ; then
	echo "Already finished."
else
	echo $(date) $(hostname) $src_name ${RESOLUTION} $bounds_ol

	touch "${res_bn}".start

	set -x

	# Fetch and crop the data from the tindex outside of PDAL
	# So we don't get stuck with large tiles in a non-streamable
	# pipeline (readers.tindex is non-streamable as are filters.smrf, etc)
	rm -rf "${res_bn}".src.laz.tmp
	./fetch.py "${src_name}" "${res_bn}".src.laz "${bounds_i}"

	#strace -e trace=open \
	pdal pipeline all.laz.pipeline.json \
		 --readers.las.filename="${res_bn}".src.laz \
		 --stage.ndsm_writer.resolution=${RESOLUTION} \
		 --stage.ndsm_writer.bounds="${bounds_or}" \
		 --stage.ndsm_writer.filename="${res_bn}".ndsm.tif \
		 --stage.dsm_writer.resolution=${RESOLUTION} \
		 --stage.dsm_writer.bounds="${bounds_or}" \
		 --stage.dsm_writer.filename="${res_bn}".dsm.tif \
		 --stage.dem_writer.resolution=${RESOLUTION} \
		 --stage.dem_writer.bounds="${bounds_or}" \
		 --stage.dem_writer.filename="${res_bn}".dem.tif \
		 --stage.agl_writer.filename="${res_bn}".agl.las

	pdal pipeline crop.pipeline.json \
		 --readers.las.filename="${res_bn}".agl.las \
		 --filters.crop.bounds="${bounds_ol}" \
		 --writers.las.filename="${res_bn}".agl.laz

	rm "${res_bn}".agl.las

	set +x
	echo $(date) $(hostname) $src_name ${RESOLUTION} $bounds_ol Done.
	touch "${res_bn}".done
fi
