#!/usr/bin/python3

# Workaround for pdal readers.tindex is not streamable
# and uses lots of memory if there are large source tiles.

from osgeo import ogr
import os
import re
import subprocess
import sys

tindex_ds = ogr.Open(sys.argv[1])
tidx_lyr = tindex_ds.GetLayer('tindex');

out = sys.argv[2]

os.mkdir(out+".tmp")

bounds = re.match("\(\[(\d+),(\d+)\],\[(\d+),(\d+)\]\)", sys.argv[3])
minx = int(bounds[1])
maxx = int(bounds[2])
miny = int(bounds[3])
maxy = int(bounds[4])

ring = ogr.Geometry(ogr.wkbLinearRing)
ring.AddPoint(minx,miny)
ring.AddPoint(maxx,miny)
ring.AddPoint(maxx,maxy)
ring.AddPoint(minx,maxy)
ring.AddPoint(minx,miny)
poly = ogr.Geometry(ogr.wkbPolygon)
poly.AddGeometry(ring)

tidx_lyr.ResetReading()
tidx_lyr.SetSpatialFilter(poly)
idx = 0
tmpfiles = []
for t in tidx_lyr:
	idx = idx + 1
	laz = t.GetField('location')
	laz_out = out+".tmp/"+str(idx)+"-"+os.path.basename(laz)+".las"
	bounds = '([{0:6.0f},{1:6.0f}],[{2:7.0f},{3:7.0f}])'.format(
			minx,
			maxx,
			miny,
			maxy
	)
	print("Reading "+laz)

	subprocess.run([
		"pdal","pipeline",
		"fetch.pipeline.json",
		"--readers.las.filename="+laz,
		"--filters.crop.bounds="+bounds,
		"--writers.las.filename="+laz_out,
		"--writers.las.offset_x="+str(minx),
		"--writers.las.offset_y="+str(miny),
		"--writers.las.offset_z=0"
	])

	tmpfiles.append(laz_out)

print("Merging into "+out)
subprocess.run([
		"pdal","merge",
		] + tmpfiles + [ out ])
		#] + tmpfiles + [ out+".tmp/out.las" ])

#print("Removing duplicate points "+out)
#subprocess.run([
#		"pdal","translate", 
#		out+".tmp/out.las", out, 
#		"--filter=filters.sample", "--filters.sample.radius=0.001"
#])

print("Removing temp files.")
print("\t"+out+".tmp")
subprocess.run(["rm", "-rf", out+".tmp"])
