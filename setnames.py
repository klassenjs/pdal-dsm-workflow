#!/usr/bin/python3

from osgeo import gdal
import sys

ds = gdal.Open(sys.argv[1])

ds.GetRasterBand(1).SetDescription(sys.argv[2])
ds.GetRasterBand(2).SetDescription(sys.argv[3])
ds.GetRasterBand(3).SetDescription(sys.argv[4])
