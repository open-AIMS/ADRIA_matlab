# Corals

ADRIA represents six size classes of four taxonomic groups of corals.

Taxonomic groups include:

- Tabular Acropora (Enhanced and Unenhanced)
- Corymbose Acropora (Enhanced and Unenhanced)
- Small Massives
- Large Massives

Enhanced Tabular Acropora and Corymbose refer to specialized corals cultivated with aquaculture. These corals are expected to be better capable of withstanding the adverse conditions compared to corals grown in the wild.

These taxonomic groups are divided into six size classes ranging from < 2 centimeters to 80 centimeters, with bounds:

[2, 5, 10, 20, 40, 80]

Coral taxa in combination with the different size classes results in 36 different coral "species" being represented in ADRIA.

Represented parameters include:

- basecov
- growth_rate : growth rate in cm/year
- wavemort90 : 90-percentile wave mortality
- mb_rate : background mortality rate
- natad : natural adaptation rate

Each have an associated growth process, documented in [growth function]().

Growth rates are assumed to be similar between enhanced and unenhanced corals.

Coral growth are represented as linear extensions between their size classes.
A proportion of the smaller size classes grow and move up a size class every time step (i.e., a year).


# References

Bozec, Y.-M., Rowell, D., Harrison, L., Gaskell, J., Hock, K., Callaghan, D., Gorton, R., Kovacs, E. M., Lyons, M., Mumby, P., & Roelfsema, C. (2021). Baseline mapping to support reef restoration and resilience-based management in the Whitsundays. https://doi.org/10.13140/RG.2.2.26976.20482

Baskett, M. L., Fabina, N. S., & Gross, K. (2014). Response Diversity Can Increase Ecological Resilience to Disturbance in Coral Reefs. The American Naturalist, 184(2), E16–E31. https://doi.org/10.1086/676643

Fabina, N. S., Baskett, M. L., & Gross, K. (2015). The differential effects of increasing frequency and magnitude of extreme events on coral populations. Ecological Applications, 25(6), 1534–1545. https://doi.org/10.1890/14-0273.1

Popov, V., Shah, P., Runting, R. K., & Rhodes, J. R. (2021). Managing risk and uncertainty in systematic conservation planning with insufficient information. Methods in Ecology and Evolution, 2041-210X.13725. https://doi.org/10.1111/2041-210X.13725
