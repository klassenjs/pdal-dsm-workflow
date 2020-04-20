#!/usr/bin/python3

from osgeo import ogr,osr,gdal
import sys

tindex_ds = ogr.Open(sys.argv[1])
tidx_lyr = tindex_ds.GetLayer('tindex');

geocell_ds = ogr.Open(sys.argv[2], 1)
geocell_lyr = geocell_ds.GetLayer('grid')
geocell_defn = geocell_lyr.GetLayerDefn()

deleteFIDS = []
for geocell in geocell_lyr:
	geocell_geom = geocell.GetGeometryRef()
	geocell_env = geocell_geom.GetEnvelope()

	geocell_east = geocell_env[0]
	geocell_north = geocell_env[2]

	# Find if this geocell contains any input data
	geocell_has_data = False

	tidx_lyr.ResetReading()
	tidx_lyr.SetSpatialFilter(geocell_geom)
	for t in tidx_lyr:
		geocell_has_data = True

	if geocell_has_data == False:
		deleteFIDS.append(geocell.GetFID())
# end for

geocell_ds.StartTransaction()

for fid in deleteFIDS:
	geocell_lyr.DeleteFeature(fid)

geocell_ds.CommitTransaction()
