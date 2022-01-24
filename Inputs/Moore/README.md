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

Degree Heating Weeks


**connectivity**

Connectivity matrices from RECOM runs, provided by B. Robson.

