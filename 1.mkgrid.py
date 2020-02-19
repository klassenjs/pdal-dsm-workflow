#!/usr/bin/python3

"""
This script takes a 3000x3000m polygon grid as input
     X:123000,765000  Y:4812000,5475000

It removes grid cells without any input data.  This includes grid cells that
do not overlap the lidar tileindex as well as grid cells found from previous
runs to not contain any ground points (or likely any points).  (This is due
to the 3km grid an the lidar tiles not being aligned so a 3km grid may overlap
a lider tile's bounding box but not any of the lidar tile's points).

It splits the 3km grid into a 750m grid where needed to keep PDAL memory use
below 5750 MB.  This includes the higher density (2-10 pt/sq.m.) metro area
and some greater MN areas.  The greater MN areas were found by trial and error
from previous runs and stored in the file 'need-1k-grid'.

The output is a mixed 3k and 750m grid that can optimally drive 2.submit.py
which creates the actual jobs to run PDAL.
"""

from osgeo import ogr,osr,gdal

tindex_ds = ogr.Open('./src/Elevation/Statewide_Low_Density_Lidar.gpkg')
tidx_lyr = tindex_ds.GetLayer('tindex');

geocell_ds = ogr.Open('./grid.gpkg', 1)
geocell_lyr = geocell_ds.GetLayer('grid')
geocell_defn = geocell_lyr.GetLayerDefn()

need_1k_grid = []
with open("need-1k-grid") as file:
	for line in file:
		[x, y] = line.split('_')
		x = int(x)
		y = int(y)
		need_1k_grid.append([x,y])


no_ground_points = []
with open("no-ground-points") as file:
	for line in file:
		[x, y] = line.split('_')
		x = int(x)
		y = int(y)
		no_ground_points.append([x,y])

def make_1k_grid(minx, miny, grid_step):
	#grid_step = 750
	for dx in range(0, 3000, grid_step):
			for dy in range(0, 3000, grid_step):
				x1 = minx + dx
				y1 = miny + dy
				ring = ogr.Geometry(ogr.wkbLinearRing)
				ring.AddPoint(x1, y1)
				ring.AddPoint(x1+grid_step, y1)
				ring.AddPoint(x1+grid_step, y1+grid_step)
				ring.AddPoint(x1, y1+grid_step)
				ring.AddPoint(x1, y1)
				poly = ogr.Geometry(ogr.wkbPolygon)
				poly.AddGeometry(ring)
				feat = ogr.Feature(geocell_defn)
				feat.SetGeometry(poly)
				geocell_lyr.CreateFeature(feat)

deleteFIDS = []
split1k = []
for geocell in geocell_lyr:
	geocell_geom = geocell.GetGeometryRef()
	geocell_env = geocell_geom.GetEnvelope()

	geocell_east = geocell_env[0]
	geocell_north = geocell_env[2]

	# Find if this geocell contains any input data
	geocell_has_data = False
	geocell_split_1k = 0

	tidx_lyr.ResetReading()
	tidx_lyr.SetSpatialFilter(geocell_geom)
	for t in tidx_lyr:
		location = t.GetField('location')
		if (len(location) >= 78):
			# len(location) >= 78 selects the mid res metro tiles
			geocell_split_1k = 1500
		if (len(location) >= 80):
			# len(location) >= 80 selects the high res metro tiles
			geocell_split_1k = 750
		geocell_has_data = True

	for [x, y] in need_1k_grid:
		if (x == geocell_east and y == geocell_north
			and geocell_has_data
			and geocell_split_1k == 0):
			geocell_split_1k = 1500

	for [x, y] in no_ground_points:
		if (x == geocell_east and y == geocell_north):
			geocell_has_data = False
			geocell_split_1k = 0

	if geocell_split_1k > 0:
		split1k.append([geocell_east, geocell_north, geocell_split_1k])
		deleteFIDS.append(geocell.GetFID())
	if geocell_has_data == False:
		deleteFIDS.append(geocell.GetFID())
# end for

geocell_ds.StartTransaction()

for fid in deleteFIDS:
	geocell_lyr.DeleteFeature(fid)

for [x, y, step] in split1k:
	make_1k_grid(x,y,step)

geocell_ds.CommitTransaction()
