#!/usr/bin/python3

from osgeo import ogr,osr,gdal
import math
import os
import subprocess

tindex_ds = ogr.Open('./src/Elevation/Statewide_Low_Density_Lidar.gpkg')
geocell_ds = ogr.Open('./grid.gpkg')
	# This is a 3000x3000m grid in UTM15
	# X:123000,765000  Y:4812000,5475000

tidx_lyr = tindex_ds.GetLayer('tindex');
geocell_lyr = geocell_ds.GetLayer('grid')

for geocell in geocell_lyr:
	geocell_geom = geocell.GetGeometryRef()
	geocell_env = geocell_geom.GetEnvelope()
	geocell_srs = geocell_geom.GetSpatialReference()

	geocell_east = geocell_env[0]
	geocell_north = geocell_env[2]

	geocell_name = "{0:06.0f}".format(geocell_east) + "_" + \
				   "{0:07.0f}".format(geocell_north)

	#print(geocell_env)
	#print("Geocell: "+geocell_name)

	# Find Input DEMs within this geocell
	geocell_has_data = False

	tidx_lyr.ResetReading()
	tidx_lyr.SetSpatialFilter(geocell_geom)
	for t in tidx_lyr:
		location = t.GetField('location')
		if (len(location) < 78):
				# len(location) < 78 skips the high res metro tiles
				geocell_has_data = True
				break

	# Setup job parameters
	tindex_name = './src/Elevation/Statewide_Low_Density_Lidar.gpkg'
	bounds_i = '([{0:6.0f},{1:6.0f}],[{2:7.0f},{3:7.0f}])'.format(geocell_env[0]-100,geocell_env[1]+100,geocell_env[2]-100,geocell_env[3]+100)
	bounds_o = '([{0:6.0f},{1:6.0f}],[{2:7.0f},{3:7.0f}])'.format(geocell_env[0],geocell_env[1]-3,geocell_env[2],geocell_env[3]-3)
	output_bn = './results.2/' + geocell_name

	already_done = os.path.exists(output_bn+'.done')
	if (geocell_has_data and not already_done):
		subprocess.run(["sbatch",
						"-J", geocell_name,
						"-o", output_bn+'.log',
						"./run-chm.sh", tindex_name, output_bn, bounds_i, bounds_o
		])
# end for
