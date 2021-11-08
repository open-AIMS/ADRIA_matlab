## Readme for using ADRIA_app_example2.mlapp ##

# Setting up toolboxes #
- ADRIA_app_example2.mlapp does not require any of the ADRIA functions/files to run, only the data and functions contained in the ADRIA_BBN_app folder
- It does, however, require the BANSHEE toolbox with some alterations
- the BANSHEE toolbox is free through the Matlab add-ons tab (alternatively on their Github [here](https://github.com/dompap/BANSHEE)
- download BANSHEE then run >> open bn_visualize in the command window of Matlab
- copy the contents of the file 'bn_visualize_copy.m' in the folder ADRIA_BBN_app. This is an altered version of the function with some customized plotting and inputs to suit the app structure syntax.

- note this is very much a draft/in progress. Some major issues to keep in mind are: 
	- You can currently choose some values that are not available in the data set (the .csv file) which throws an error (this will be fixed when I run a larger parameter set on the hpc)
	- currently does not include any reflow to allow resizing of the interface, I have played around with this in some commented code but will fully test later.

- other things which will change/I'm working towards are:
	- allowing probability distribution representations of the metric inference page
	- different representations of the intervention parameters/outcomes on the metric inference page and parameter inference pages