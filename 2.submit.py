#!/usr/bin/python3

from osgeo import ogr,osr,gdal
import math
import os
import subprocess

# Location of the source data tileindex
tindex_name = './src/Elevation/Statewide_Low_Density_Lidar.gpkg'

# Meters to buffer the geocell boundary when selecting input data (to avoid edge artifacts)
geocell_buffer = 30

# output resolution (meters)
resolution = 3

# output directory
output_dir = './results.3/tiles'

# This the geocell grid to split processing
geocell_ds = ogr.Open('./grid.gpkg')
geocell_lyr = geocell_ds.GetLayer('grid')

for geocell in geocell_lyr:
	geocell_geom = geocell.GetGeometryRef()
	geocell_env = geocell_geom.GetEnvelope()

	geocell_east = geocell_env[0]
	geocell_north = geocell_env[2]

	geocell_name = "{0:06.0f}".format(geocell_east) + "_" + \
				   "{0:07.0f}".format(geocell_north)

	#print("Geocell: "+geocell_name)

	# Setup job parameters
	bounds_i = '([{0:6.0f},{1:6.0f}],[{2:7.0f},{3:7.0f}])'.format(
			geocell_env[0] - geocell_buffer,
			geocell_env[1] + geocell_buffer,
			geocell_env[2] - geocell_buffer,
			geocell_env[3] + geocell_buffer
	)
	bounds_o = '([{0:6.0f},{1:6.0f}],[{2:7.0f},{3:7.0f}])'.format(
			geocell_env[0],
			geocell_env[1] - resolution,
			geocell_env[2],
			geocell_env[3] - resolution
	)
	output_bn = output_dir + geocell_name

	already_done = os.path.exists(output_bn+'.done')
	if (not already_done):
			subprocess.run([
					"sbatch",
					"-J", geocell_name,
					"-o", output_bn+'.log',
					"./run-chm.sh",
						tindex_name, output_bn,
						bounds_i, bounds_o,
						str(resolution)
			])
# end for
