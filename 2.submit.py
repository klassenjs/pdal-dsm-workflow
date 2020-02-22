#!/usr/bin/python3

from osgeo import ogr,osr,gdal
import math
import os
import sys
import subprocess

# Location of the source data tileindex
tindex_name = './src/Elevation/Statewide_Low_Density_Lidar.gpkg'

# Meters to buffer the geocell boundary when selecting input data (to avoid edge artifacts)
geocell_buffer = 30

# output resolution (meters)
resolution = 3

# output directory (needs trailing /)
output_dir = './results.4/tiles/'

# sanity checks
if not os.path.isfile(tindex_name):
	print("Input tileindex '"+tindex_name+"' does not exist.")
	exit(1)

if not os.path.isdir(output_dir):
	print("Output directory '"+output_dir+"' doesn't exist.")
	exit(1)

# This the geocell grid to split processing (assumed rectangular in UTM)
geocell_ds = ogr.Open('./grid.gpkg')
geocell_lyr = geocell_ds.GetLayer('grid')

# Submit jobs for each gridcell
for geocell in geocell_lyr:
	geocell_geom = geocell.GetGeometryRef()
	geocell_env = geocell_geom.GetEnvelope()

	geocell_east = geocell_env[0]
	geocell_north = geocell_env[2]

	geocell_name = "{0:06.0f}".format(geocell_east) + "_" + \
				   "{0:07.0f}".format(geocell_north)

	#print("Geocell: "+geocell_name)

	# Setup job parameters

	# Bounds to filter input points
	bounds_i = '([{0:6.0f},{1:6.0f}],[{2:7.0f},{3:7.0f}])'.format(
			geocell_env[0] - geocell_buffer,
			geocell_env[1] + geocell_buffer,
			geocell_env[2] - geocell_buffer,
			geocell_env[3] + geocell_buffer
	)
	# Output bounds of raster (1 px short on upper-right)
	bounds_or = '([{0:6.0f},{1:6.0f}],[{2:7.0f},{3:7.0f}])'.format(
			geocell_env[0],
			geocell_env[1] - resolution,
			geocell_env[2],
			geocell_env[3] - resolution
	)
	# Output bounds of AGL LAZ file
	bounds_ol = '([{0:6.0f},{1:6.0f}],[{2:7.0f},{3:7.0f}])'.format(
			geocell_env[0],
			geocell_env[1],
			geocell_env[2],
			geocell_env[3]
	)
	output_bn = output_dir + geocell_name

	already_done = os.path.exists(output_bn+'.done')
	if (not already_done):
			subprocess.run([
					"sbatch",
					"-J", geocell_name,
					"-o", output_bn+'.log',
					"./srun-chm.sh",
						tindex_name, output_bn,
						bounds_i, bounds_or, bounds_ol,
						str(resolution)
			])
# end for
