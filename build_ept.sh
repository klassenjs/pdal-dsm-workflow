#!/bin/bash

set -eu
ulimit -v 33554432

function run() {
	out=potree/html/pointclouds/$2
	rm -rf $out
	entwine build --threads 8 -i $1 -o $out
}

#run Data/RiceCreek_TwinCities/LAS_2008 RiceCreek_2008
#run Data/RiceCreek_TwinCities/laz_2012 RiceCreek_2012
#run Data/SevenMileCreek/PC_2007 SevenMileCreek_2007
#run Data/SevenMileCreek/PC_2010 SevenMileCreek_2010
#run Data/SuperiorOverlap/lidar_2017 SuperiorOverlap_2017
#run Tools/Data/4342-01-27_a_d.laz MN-4342-01-27_a_d
#run Tools/Data/4342-08-28_b.laz MN-4342-08-28_b
#run Tools/Data/15TWN59622957.laz SO-15TWN59622957
