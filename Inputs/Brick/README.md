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

Initial dataset ("dhwRCPxx_brick.mat") created by V. Lago using IDs in "Brick_Cluster_Spatial.csv".
These have 567 sites.

Five sites were excluded from RECOM runs as they were on the edges of the spatial domain.
These are (Unique IDs from `Brick_Cluster_Spatial.csv`):

- 19194100104_1_BR_1 (table row 542)
- 19194100104_1_C_4 (row 546)
- 19194100104_1_SS_3 (row 55)
- 19194100104_1_S_4 (row 558)
- 19194100104_1_OF_2 (row 549)

The "dhwRCPxx.mat" set of files are copies of the above with these five sites removed.

e.g.:
x1.DHWdatacube(:, setdiff(1:end, [542,546,553,558,549]), :)


Note that the unmodified dataset has fields

- DHWdatacube
- lat
- lon

These have been changed to:

- dhw
- lat
- lon

As ADRIA expects DHW files to contain a `dhw` field.


**connectivity**

Connectivity matrices from RECOM runs, provided by B. Robson.

It is suggested that the average of mean connectivity for all years (e.g., an average of averages) be used as a first-pass.

These represent 354 locations. Note that the site reference table includes 355 locations but one was not captured ("L_355_v1"), hence the 354 usable sites.
As some sites share the same location, these need to be duplicated as needed to align with the 561 site locations (562 minus the missing location).

