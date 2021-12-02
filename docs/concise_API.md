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
- ptype (`categorical`, `integer`, or `float`)
- defaults
- lower_bound (min of discrete values)
- upper_bound (max of discrete values)
- options (possible discrete values for categoricals)
- raw_lower_bound (min of option values)
- raw_upper_bound (max of option values)
  
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
- ptype (`categorical`, `integer`, or `float`)
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
- con_cutoff : float, percent thresholds of max for weak connections in network (defined in ADRIAparms.m)

**Output:**
- TP_data     : table, containing the transition probability for all sites (float)
- site_ranks : table, centrality for each site
- strongpred : matrix, strongest predecessor for each site


## saveData()

Save results to file.

If file is not specified, generates a filename based on date/time

**Inputs:**
- data     : any, data to save
- filename : str (optional), file name and location to save data to
               Defaults to `ADRIA_results_[current time].csv` if nothing specified.
- dim_spec : cell array (optional), name/dimensions of `data`.
               Required for 'nc'.
               e.g., `{'x_name', x_data, 'y_name', y_data}`
- nc_varname : str (optional), variable name to save data to in the
               NetCDF file. Required for 'nc'.

Usage Example:

```matlab
% Example random data
data = rand(5,5)

% These are equivalent
saveData(data, 'example')
saveData(data, 'example.csv')

% Saving the 5x5 dimension array to NetCDF
saveData(data, 'example.nc', {'x', 5, 'y', 5}, 'varname')
```

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

## ADRIA_DMCDA()
Allows selection from 3 MCDA algorithms to make dynamic site selection decisions within ADRIA. Selection decisions are based on a decision matrix A,
which currently incoporates connectivity, wave stress, heat stress, coral cover and priority predecessors as criteria. Each algorithm carries out a different decision strategy:

1 : order ranking
   - ranks sites according to additive ranking
   - rank calculated from the sum of the columns of A
   - Strategy: When overall performance matters and trade-offs between criteria need not be considered (also least computationally expensive).
   
2 : TOPSIS
   - ranks sites according a ratio 
   - ratio is calculated from the geometric distance from the Positive Ideal Solution PIS and Negative Ideal Solution NIS
   - See Hsu-Shih Shih, Huan-Jyh Shyur, E. Stanley Lee, 2007 An extension of TOPSIS for group decision making, Mathematical and Computer Modelling, vol. 45:7–8.
   - Strategy: When trade-offs between criteria should be considered, but it is not necessary to avoid hidden value extremes.

3 : VIKOR 
   - ranks sites according to a linear combination of  two measures, S and R.
   - S measures 'group utility', or the performance of site x against all criteria
   - R measures 'individual regret', or the maximum deviance of site x from the best ranked sites under all criteria
   - weightings of R and S in the linear combination are chosen to balance group utility and individual regret (currently both set at 0.5)
   - See Alidrisi, Hisham, 2021 An Innovative Job Evaluation Approach Using the VIKOR Algorithm, Journal of Risk and Financial Management, vol. 14:6.
   - Strategy: When trade-offs between criteria should be considered and the decision-maker wants to weight against potential poorly performing criteria which can       be hidden in trade-offs.

**Inputs:**
- DMCDAvars    : a structure of the form struct('nsites', [], 'nsiteint', [], ...
      'strongpred', [], 'centr', [], 'damprob', [], 'heatstressprob', [], ...
      'prioritysites', [], 'sumcover', [], 'risktol', [], 'wtconseed', [], ...
      'wtconshade', [],'wtwaves', [], 'wtheat', [], 'wthicover', [], ...
      'wtlocover', [], 'wtpredecseed', [], 'wtpredecshade', []);
      where []'s are dynamically updated in runADRIA.m
      
      - nsites : total number of sites
      - nsiteint : number of sites to select for priority interventions
      - strongpred : strongest predecessor sites (calculated in ADRIA_TP_Moore())
      - centr : site centrality (calculated in ADRIA_TP_Moore())
      - damprob : probability of coral wave damage for each site
      - heatstressprob : probability of heat stress for each site
      - prioritysites : list of sites in group (i.e. prsites: 1,2,3)
      - sumcover : total coral cover
      - risktol : risk tolerance (input by user from criteriaWeights/Details)
      - wtconseed : weight of connectivity for seeding
      - wtconshade : weight of connectivity for shading
      - wtwaves : weight of wave damage
      - wtheat : weight of heat risk
      - wthicover : weight of high coral cover
      - wtlocover : weight of low coral cover
      - wtpredecseed : weight for seeding predecessors of priority reefs
      - wtpredecshade : weight for shading predecessors of priority reefs
      
- alg_ind   : an integer indicating the algorithm to be used for the multi-criteria anlysis 
      (1: order-ranking, 2: TOPSIS, 3: VIKOR, 4: multi-obj ranking

**Output:**
- prefseedsites : array of recommended best sites for seeding
- prefshadesites : array of recommended best sites for shading
- nprefseedsites : number of seeding sites chosen by MCDA
- nprefshadesites : number of shading sites chosen by MCDA

## multiObjOptimisation()
multiObjOptimisation takes variables for RCP and  and runs an optimisation algorithm to maximise outputs with
respect to the intervention variables Guided, PrSites, Seed1, Seed2, SRM, AaAdpt, NatAdpt, Seedyrs, Shadeyrs, wave_stress, heat_stress, 
shade_connectivity, seed_connectivity, coral_cover_high, coral_cover_low, seed_priority, shade_priority, deployed_coral_risk_tol.
If 2 inputs, will use shell variables for ES_vars and RCP. If > 2 inputs, will use these as ES_sites and RCP.

** Inputs :**
- alg : indicates MCDA algorithm to be used
             1 - Order Ranking
             2 - TOPSIS
             3 - VIKOR
- out_names: indicates which outputs to optimise over as a cell structture of strings
                  e.g. out_names = {'TC','CES','PES'};
- fn: string giving file location within GitRepo of DHW data for reef of interest
- TP_data: structure generated from ADRIA_TP function
- site_ranks : structure generated from ADRIA_TP function
- strongpred : structure generated from ADRIA_TP function
- varargin : default values used if not specified
- varargin{1} : rcp (rcp scenario value 2.6,4.5,6.0,8.5)
- varargin{2} : ES_vars (1*7 array with structure [evcult, strcult, evprov, 
                               strprov,TCsatCult,TCsatProv,cf])
                               
**Outputs:**
- x : [Guided, PrSites, Seed1,Seed2,SRM,Aadpt,Natad, AaAdpt, NatAdpt, Seedyrs, Shadeyrs, wave_stress, heat_stress, 
       shade_connectivity, seed_connectivity, coral_cover_high, coral_cover_low, seed_priority, 
       shade_priority, deployed_coral_risk_tol]
- fval : the max value/optimal value of the chosen metrics 

See also:
    [`allParamMultiObjectiveFunc()`](#allparammultiobjectivefunc)
   
**Example:**
```matlab
%% Example for simple usage of the optimisation function ADRIAOptimisation
%% 1 : only optimise for average total coral cover av_TC

% use simplest MDCA algorithm for now
alg = 1;

rcp = 60;

% optimisation specification - want to optimise TC and CES
names_vec = cell(2,1);
names_vec{1} = 'TC';
names_vec{2} = 'CES';

% load Moore reef data
[TP_data, site_ranks, strongpred] = ADRIA_TP('Inputs/MooreTPmean.xlsx', 0.1);
fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(rcp), ".nc");

% perform optimisation (takes a while, be warned, improvements to
% efficiency to be made)
[x,fval] = multiObjOptimization(alg, names_vec, fn, TP_data, site_ranks, strongpred,rcp);

% print results (also automatically saved to a struct in a .mat file) 
sprintf('Optimal intervention values were found to be Seed1: %1.4f, Seed2: %1.4f, SRM: %2.0f, AsAdt: %2.0f, NatAdt: %1.2f, with av_TC = %1.4f',...
    x(1),x(2),x(3),x(4),x(5),fval);


```  

## allParamMultiObjectiveFunc() 
Formulation of runADRIA which allows for optimisation as an objective function with conventional Matlab optimisation functions. Gives TC, S, C,
CES and PES as possible outputs, as specified in tgt_names.
Currently averages over space and time to acheive suitable format (more descriptive formats such as distribution summary statistics, 
kdes etc may come in later versions).

**Input:**
- x             : array, perturbed parameters
- alg           : int, ranking algorithm 
- tgt_names      : cell of strs, name of output to optimize (TC, E, S, CES, PES)
- combined_opts : table, ADRIA parameter details
- nsites        : int, number of sites
- wave_scens    : matrix, available wave damage scenarios
- dhw_scens     : matrix, available DHW scenarios
- params        : array, core ADRIA parameter values (TO BE REPLACED)
- ecol_parms    : array, ADRIA ecological parameter values (TO BE REPLACED)
- TP_data       : array, Transition probability data
- site_ranks    : array, site centrality data
- strongpred    : array, data indicating strongest predecessor per site
    
**Output:** 
- av_res : average result (specified by tgt_name) over time/sites, as an array of dimension 1*(length of tgt_names)
      
