#!/bin/bash

set -euo pipefail

#entwine scan --output ept-scan --input tiles/*.laz

MYDIR="$(dirname "$0")"
for i in $(seq 16) ; do
	sbatch \
		-J entwine-$i \
		-o entwine-$i.log \
		$MYDIR/srun-entwine.sh $i
done

#entwine merge --output ept
