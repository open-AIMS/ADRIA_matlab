# ADRIA_repo
Repository for the development of the ADRIA dynamic multi-criteria decision making model.

## Version: FILL THIS WHEN UPLOADED

### Summary

Climate change is transforming coral reefs. Continued climate change has scope to erode reef biodiversity, key ecosystem functions, and the ecosystem services they provide for people. Conventional management strategies remain essential but will not be sufficient on their own to sustain coral reefs in a warming and acidifying ocean. New interventions are increasingly being considered, including assisted gene flow, cooling and shading, and reef structures that provide reef habitats and substrates for enhanced recruitment. 

Deciding where, when, and how to intervene – if at all - using new reef restoration and adaptation measures is challenging on at least three fronts. Firstly, are new interventions likely to create more benefits than damage? And if so, whom do they benefit, or pose risks to, and at what spatial and temporal scales?  Secondly, which interventions, individually and in combination, represent solutions that provide the highest return on investment for reef, people, and industries? Thirdly, which R&D paths and deployment strategies represent optimal solutions given multiple key objectives, trade-offs, and limited time, resources, and logistical constraints?            

To help reef modellers, decision-support teams and reef managers address these questions, AIMS has developed the Adaptive, Dynamic Reef Intervention Algorithm (ADRIA). In short, ADRIA simulates a reef decision maker operating inside the dynamic state space of a coral reef. For reef managers, ADRIA help provide line of sight to conservation solutions in complex settings where multiple objectives need to be considered. For investors, ADRIA helps analysts identify which options (R&D and/or deployment solutions) might have the highest likelihood of providing ecological and social returns on investment. While ADRIA’s key function is as a decision-support tool for intervention deployment, it uses a simple proxy model for reef coral dynamics, consisting of vital rates parameterised in a set of linked differential equations for four coral groups. The growth, mortality and recruitment of those four coral groups are further parameterised by environmental drivers and by different restoration and adaptation interventions.   
 
The primary purpose of ADRIA is to help guide intervention deployment such that net benefits are maximised against primary objectives and minimised against costs. Solutions can be tuned (eventually optimised) via heuristics that control the selection of sites and/or reefs and the prioritisation of species, ecosystem services or benefits that favour what people (society) want. The key benefits considered in ADRIA are consistent with a triple-bottom-line approach, i.e. (1) ecological (e.g. biodiversity), (2) economic (e.g. tourism and fisheries values) and (3) social and cultural (e.g. recreation and supporting identities).    

The guiding principles for decision support in ADRIA are currently a set of dynamic multi-criteria decision analyses (dMCDA) applied at each time step. Criteria in the model are a composite of spatial environmental variables (risk from wave damage, thermal stress, and water quality) and ecological information (coral cover, substrate availability). 

ADRIA is currently set up for the Moore Reef cluster: 26 sites in a cluster of four reefs off Cairns in North Queensland.  The intent is to broaden the set of case studies we can inform, including Whitsundays, and at different spatial scales.  

At the end of this document are the evolving set of scripts that combine to form ADRIA.   

Two main scripts will get you started:  runADRIAmain and analyseADRIAresults1.  

### Key scripts and their run order

* *ADRIAparms (script)*: Loads environmental and biological/ ecological model parameters into memory.
* *setupADRIAsims (script)*: Prepares the main program by loading files and saving data structures.
* *CriteriaWeights (function)*: Asks user for input regarding the weights used in the multi-criteria decision analysis (MCDA) for intervention deployment.
* *InterventionTble (function)*: Generates options for intervention R\&D assumptions and deployment levels simulated by runADRIAmain. Output of this function is a control table that is used as input into runADRIAmains.
* *ReefConditionMetrics (function)*: Converts coral cover to simple metrics for functional diversity (evenness) and structural complexity.
* *MooreSites.xlsx (excel file)*: Lats, Ions and IDs for Moore Reef example sites.
* *MooreTP15.xlsx (excel file)*: Transition probabilities (larval-connectivity proxies) for RECOM larval release simulations in the spawning season of 2015.
* *MooreTP16.xlsx (excel file)*: Transition probabilities (larval-connectivity proxies) for RECOM larval release simulations in the spawning season of 2016.
* *MooreTP17.xlsx (excel file)*: Transition probabilities (larval-connectivity proxies) for RECOM larval release simulations in the spawning season of 2017.
* *runADRIAmain (script)*: Main execution file.
* *ADRIA_TP_Moore (function)*:Generates transition probability matrices for larval connectivity and generates time series of environmental conditions with different connectivity patterns.
* *ADRIA_TP (.mat file)*: Data file produced by ADRIA_TP_Moore.
* *swhMoore.xlsx (excel file)*: Table with significant wave heights for the 26 example sites on and around the Moore Reef off Cairns.
* *ADRIA_wavedist (.mat file)*: Data file produced by setupADRIAsims.
* *ADRIA_dhwMoore (function)*: Calls NetCDF files from RECO runs.
* *MooreDHWs (.mat file)*: Stored DHW data.
* *ADRIA_DHWprojectfun (function)*: Produces DHW projections for example sites given RCP.
* *ADRIA_dhwdisttime (.mat file)*: Projected DHW data produced by setupADRIAsims.
* *ADRIA_larvalprod (function)*: Simulates effect of past heat stress on coral fecundity using Gompertz function.
* *ADRIA_DMCDA (function)*: Multicriteria analysis for site selection at each timestep.
* *ADRIA_bleachingmortalityfun (fuction)*: Bleaching mortality response function based on Hughes 2018. Uses Gompertz function where parameter 2 varies with thermal tolerance.
* *ADRIA4groupsODE (function)*: ODE model for the simple coral community using a pulse impulsive approach.
* *analyseADRIAresults1 (script)*: Analyses outputs of runADRIAsims.
* *ADRIA_display_dhw_Moore (script)*: Displays DHWs for years 2016, 2017 and 2020.
* *MooreSites_GE (script)*: Generates kml file that can display the location of Moor Reef sites in Google Earth.
* *distributionPlot (function)*: Plots results of ADRIA simulations as violin plots (distributions).
