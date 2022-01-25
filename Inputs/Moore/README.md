Overview of data included in this directory:

*site_data*

Spatial data relating to the Moore cluster (from A. Cresswell).

This dataset should match with what the IPMF team is using.

Consists of a shapefile and CSV. The CSV holds identical attribute data
as the shapefile.

- Moore_cluster_poly.shp (and associated files)
- MooreReefCluster_Spatial.csv
- MooreReefCluster_Spatial_with_DHW_corrected.xlsx

It holds:
- site_id
- habitat
- area (in m^2 ???)
- rubble (true or false)
- k, maximum carrying capacity for the associated site (in percentage values, gets divided by 100 in ADRIA)
- Reef
- reef_siteid
- long
- lat
- sitedepth
- recom_connectivity, should align with cell ID in RECOM connectivity data

The `MooreReefCluster_Spatial_with_DHW_corrected.xlsx` includes maximum DHWs for each site for 2015, 2017, and 2020.
These were extracted from a collection of netCDF files (referred to as the "Robson files") using the script `ADRIA_dhwMoore_new.m`
(see inside the `scripts` folder).

The maximum DHWs were manually extracted alongside the site_ids to create the MooreDHWs.csv file in the `DHWs` directory (see below)


**DHWs**

Degree Heating Weeks datasets.

- MooreDHWs.csv : 
      DHWs for 2016, 2017 and 2020 (extreme bleaching event years)
      extracted from `MooreReefCluster_Spatial_with_DHW.csv`.
      Dataset derived from Robson files.
- StochasticDHW.csv :
- MooreCluster_maxDHW_MIROC5_2021_2099.csv :
- dhwRCP45.mat : file generated with `makeDhwProjection(tf,resdhwsites,dhwmax25,RCP,wb1,wb2, sims)`

where:

tf = 50;  length of runs
wb1 = 0.55;  parameter 1 in Weibull dist
wb2 = 2.24; parameter 2 in Weibull dist
RCP = 45;  the scenario we’re using for the business case
dhwmax25 = 3  (DHW intercept at year 2025)
sims = 50;  
resdhwsites (these are the DHW residuals produced in ‘ADRIA_dhwMoore_new()’).

The last needs to be cleaned up.
The last will also be replaced with a more robust approach.

**connectivity**

Connectivity matrices from RECOM runs, provided by B. Robson.

