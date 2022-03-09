Overview of data included in this directory:

**site_data**

Spatial/site data relating to the Brick cluster (from B. Robson).

Consists of a geopackage, shapefile, and CSVs with identical data.

They hold:

"","lat","long","siteref","site_id","habitat","area","rubble","k","Reef","reef_siteid","x","y"

- site_id, non-unique site id
- habitat
- area (in m^2)
- rubble (true or false)
- k, maximum carrying capacity for the associated site (in percentage values, gets divided by 100 in ADRIA)
- Reef, name of reef
- reef_siteid, unique id of site
- long
- lat
- x, position in spatial grid (?)
- y, position in spatial grid (?)


CSV with suffix "_reftable.csv" applies to all years and have been manually modified to include a `sitedepth` column (filled with 0, indicating unused) and 
a `recom_connectivity` column, which is the `siteref` column with an additional version suffix.


`coralCoversBrickData.mat`

Initial coral covers for the 567 reef/sites, taken from ReefMod counterfactual data. Values for each reef/sites
are assigned based on the Euclidean distance between the site long/lat (assumed to be centroids) and reefs indicated by GBR spatial data 
(TODO: detail which spatial data was used).

Saved as a struct with entry "covers".


`coralCoversBrickTruncated.mat`

As above but truncated to 562 reef/sites, and transformed so that the order of dimensions are "species" then "sites".


**DHWs**

Degree Heating Weeks datasets.


**connectivity**

Connectivity matrices from RECOM runs, provided by B. Robson.

It is suggested that the average of mean connectivity for all years (e.g., an average of averages) be used as a first-pass.

