# Concise API Overview

A non-exhaustive overview of high-level ADRIA functions.

The functions documented below form the core API through which developers interact with ADRIA.

WARNING: These functions and accompanying documentation are still under development and their names, expected inputs, outputs, and usage may change.


## interventionDetails()

Detail intervention parameter values and expected ranges.
Default values for each intervention option can be specified
to override defaults.

**Inputs:**

   Argument list of parameters to override.
   Possible arguments (with default values):

- Guided   : [0, 1]
- PrSites  : 3
- Seed1    : [0, 0.0005, 0.0010]
- Seed2    : 0
- SRM      : 0
- Aadpt    : [6, 12]
- Natad    : 0.05
- Seedyrs  : 10
- Shadeyrs : 1

**Outputs:**

Table of 

- name
- ptype (`categorical` or `float`)
- defaults
- lower_bound (min/max of discrete values)
- upper_bound
- options (possible discrete values for categoricals)
- raw_lower_bound (min/max of option values)
- raw_upper_bound (min/max of option values)
  
The `raw_*_bound` columns hold the raw values prior to any transformation,
and maps option IDs to their ADRIA expected values.

The `lower/upper` columns indicates the min/max range of option IDs for
categorical values, and are simply copies if the options are real-valued.


## criteriaDetails()

Detail criteria weight values and expected ranges.
Default values for each criteria/option can be specified
to override default values.

**Inputs:**

Argument list of parameters to override.
Possible arguments (with default values):
- wave_stress             : 1
- heat_stress             : 0
- shade_connectivity      : 0
- seed_connectivity       : 0
- coral_cover_high        : 0
- coral_cover_low         : 0
- seed_priority           : 1
- shade_priority          : 0
- deployed_coral_risk_tol : 1

**Outputs:**

Table of 

- name
- ptype (`categorical` or `float`)
- defaults
- lower_bound (min/max of discrete values)
- upper_bound
- options (possible discrete values for categoricals)
- raw_lower_bound (min/max of option values)
- raw_upper_bound (min/max of option values)
  
The `raw_*_bound` columns hold the raw values prior to any transformation,
and maps option IDs to their ADRIA expected values.

The `lower/upper` columns indicates the min/max range of option IDs for
categorical values, and are simply copies if the options are real-valued.


## coreParamDetails()

TBD


## ecolParamDetails()

TBD


## convertScenarioSelection()

Converts selected discrete values back to their categorical options.

If a parameter is of type `categorical` and can be `A` or `B`
The possible categorical options are `1 => A` and `2 => B`.

The `sel_values` array will hold values of `1` or `2`, and
this function maps this back to `A` or `B` for use with ADRIA.

**Inputs:**

- sel_values : table, of selected parameter values
- p_opts     : table, of parameter options (value ranges, etc)

**Outputs:**

- converted : table, of selected parameter values mapped back to their actual values.

See also:
    [`interventionDetails()`](#interventiondetails), [`criteriaDetails()`](#criteriadetails)


## ADRIA_TP()

Create transitional probability matrix indicating connectivity between
sites, level of centrality, and the strongest predecessor for each site.

**Inputs:**
- file       : str, path to data file to load
- con_cutoff : float, percent thresholds of max for weak connections in  network (defined in ADRIAparms.m)

**Outputs:**
- TP_data     : table, containing the transition probability for all sites (float)
- site_ranks : table, centrality for each site
- strongpred : matrix, strongest predecessor for each site


## runADRIAScenario()

Run a single intervention scenario with given criteria and parameters
If each input was originally a table, this is equivalent to a running 
a single row from each (i.e., a unique combination of intervention and parameter values)

**Inputs:**
- interv      : table, row of intervention table
- criteria    : table, row of criteria weights table
- params      : table, row of environment parameter permutations
- ecol_params : table, row of ecological parameter permutations
- wave_scen   : matrix[timesteps, nsites], spatio-temporal wave damage scenario
- dhw_scen    : matrix[timesteps, nsites], degree heating weeek scenario
- alg_ind     : int, algorithm choice (1, 2, 3)

**Example: [UNFINISHED]**
```matlab
%% Set up parameters
interv = interventionDetails();
criteria = criteriaDetails();
p_opts = [interv; criteria];  % join tables together

X ...;  % some sampling process

% map back to categorical options as necessary
X = convertScenarioSelection(X, p_opts)

% other parameters are static 
% environmental and ecological parameter values etc
[params, ecol_params] = ADRIAparms();

%% Load site data
[F0, xx, yy, nsites] = ADRIA_siteTable('MooreSites.xlsx');
[TP_data, site_ranks, strongpred] = ADRIA_TP('MooreTPmean.xlsx', params.con_cutoff);

ninter = height(X, 1);
alg_ind = 1;

%% Set up result array
Y = ... % some NxD array where N is no. of sims and D is no. of outputs

%% Run simulations
parfor i = 1:ninter
    Y(i) = runADRIAScenario(IT(i, :), criteria_weights(i, :), ...
                            param_tbl(i, :), ecol_tbl(i, :), ...
                            TP_data, site_ranks, strongpred, nsites, ...
                            w_scen, d_scen, alg_ind);
end

%% Save results
ADRIA_saveResults(Y, "example_results.mat")
```

# Utility functions


## ADRIA_saveResults()

Save results to file.

If file is not specified, generates a filename based on date/time

**Inputs:**
- data     : any, data to save
- filename : str, file name and location to save data to


## estimateRuntime()

Estimate total runtime for a given number of simulations to be run.

NOTE: 
Assumes all detected cores are used.
These are indicative estimates only with no guarantee of accuracy
or reliability.

**Inputs:**
- n_sims : int, number of simulations to be run

**Outputs:**
- est : float, estimated runtime (in seconds)
