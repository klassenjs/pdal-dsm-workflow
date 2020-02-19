#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --mem=5750
##SBATCH --mem=11500
##SBATCH --mem=23000
#SBATCH --open-mode=append

set -euxo pipefail

src_name="$1"
res_bn="$2"
bounds_i="$3"
bounds_o="$4"
RESOLUTION="$5"

if [ ! -f "${res_bn}".done ] ; then

		res_dir="$(dirname $res_bn)"

		echo $(date) $(hostname) $src_name $bounds_o

		mkdir -p "${res_dir}"

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
			 --stage.agl_writer.filename="${res_bn}".agl.laz

		echo $(date) $(hostname) $src_name $bounds_o Done.
		touch "${res_bn}".done
else
		echo "Already finished."
fi
