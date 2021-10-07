# ADRIA_repo
Repository for the development of ADRIA: Adaptive Dynamic Reef Intervention Algorithm.

## Version: Ken's version from 26 Aug 2021 

### Summary (now outdated once Rose and Vero replace with their versions) 

Climate change is transforming coral reefs. Continued climate change has scope to erode reef biodiversity, key ecosystem functions, and the ecosystem services they provide for people. Conventional management strategies remain essential but will not be sufficient on their own to sustain coral reefs in a warming and acidifying ocean. New interventions are increasingly being considered, including assisted gene flow, cooling and shading, and reef structures that provide reef habitats and substrates for enhanced recruitment. 

Deciding where, when, and how to intervene – if at all - using new reef restoration and adaptation measures is challenging on at least three fronts. Firstly, are new interventions likely to create more benefits than damage? And if so, whom do they benefit, or pose risks to, and at what spatial and temporal scales?  Secondly, which interventions, individually and in combination, represent solutions that provide the highest return on investment for reef, people, and industries? Thirdly, which R&D paths and deployment strategies represent optimal solutions given multiple key objectives, trade-offs, and limited time, resources, and logistical constraints?            

To help reef modellers, decision-support teams and reef managers address these questions, AIMS has developed the Adaptive, Dynamic Reef Intervention Algorithm (ADRIA). In short, ADRIA simulates a reef decision maker operating inside the dynamic state space of a coral reef. For reef managers, ADRIA help provide line of sight to conservation solutions in complex settings where multiple objectives need to be considered. For investors, ADRIA helps analysts identify which options (R&D and/or deployment solutions) might have the highest likelihood of providing ecological and social returns on investment. While ADRIA’s key function is as a decision-support tool for intervention deployment, it uses a simple proxy model for reef coral dynamics, consisting of vital rates parameterised in a set of linked differential equations for four coral groups. The growth, mortality and recruitment of those four coral groups are further parameterised by environmental drivers and by different restoration and adaptation interventions.   
 
The primary purpose of ADRIA is to help guide intervention deployment such that net benefits are maximised against primary objectives and minimised against costs. Solutions can be tuned (eventually optimised) via heuristics that control the selection of sites and/or reefs and the prioritisation of species, ecosystem services or benefits that favour what people (society) want. The key benefits considered in ADRIA are consistent with a triple-bottom-line approach, i.e. (1) ecological (e.g. biodiversity), (2) economic (e.g. tourism and fisheries values) and (3) social and cultural (e.g. recreation and supporting identities).    

The guiding principles for decision support in ADRIA are currently a set of dynamic multi-criteria decision analyses (dMCDA) applied at each time step. Criteria in the model are a composite of spatial environmental variables (risk from wave damage, thermal stress, and water quality) and ecological information (coral cover, substrate availability). 

ADRIA is currently set up for the Moore Reef cluster: 26 sites in a cluster of four reefs off Cairns in North Queensland.  

Note that the environmental input files (netcdfs) from Barbara's RECOM runs are not included here. Instead, transition-probability tables for connectivity are created and forward projections for DHW based on simple, linear heating rates for RCPs and based on observed spatial patterns of DHW for the study area between three bleaching years.  Vero and Barbara will be updating this.

#### Case-study: Moore Reef Cluster



