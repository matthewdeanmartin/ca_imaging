# ca_imaging


ca_bitsperspike - in prep
CAplacefieldnumDIRECTIONAL - in prep

ca_fixpos - converts position file to time, x, y and interpolates missing values
ca_mutualinfo - gets mutual info for Ca cells only in run time (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6331214/)
ca_mutualinfo_shuff - shuffles spike trains for mutual info only in run time
ca_mutualinfo_shuff_all - shuffles spike trains for mutual info in all times (NOT only in run time)
ca_raster - makes raster of times
ca_velocity - gets velocity using track pixel to cm converstion.
converttotime - converts output of getspikepeaks to matrix of times.
getspikepeaks - takes structure inputs generated by ciatah and gives you only sorted spike peaks
maketrain - makes a spike train out of sparse matrix
mutualinfo_diff - finds place cells based on MI> shuffled MI
pos_maps - plots place cell maps for a bunch of 'cells'.
pos_maps_directional - plots cell maps directionally
