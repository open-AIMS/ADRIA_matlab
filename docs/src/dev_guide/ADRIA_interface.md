# ADRIA Interface Object

The primary approach to using ADRIA is through the provided interface object.


Example:

```matlab
ai = ADRIA();

% Extract the default ADRIA values.
% This produces a parameter table with a single row defining a single simulation.
default_values = ai.raw_defaults;

%% Load site specific data
ai.loadConnectivity('MooreTPmean.xlsx');

% Run a single simulation with three replicate DHW/wave scenarios
Y = ai.run(default_values, sampled_values=false, nreps=3);

collectMetrics(Y, {@coralTaxaCover})
```

Metrics are further documented in the [metrics page](metrics.md).

The Interface object also provides access to common parameter properties and convenience methods to perform common operations on data.

```matlab
ai = ADRIA();

% Get details on specific parameter groups
ai.interventions  % equivalent to interventionDetails()
ai.criterias      % same as criteriaDetails()
ai.corals         % same as coralDetails()
ai.constants      % same as simConstants()
```

```matlab
default_values = ai.raw_defaults;

% Split parameter table into the three separate components 
% (intervention, criteria, or coral parameters)
[interventions, criterias, corals] = ai.splitParameterTable(default_values)
```

ADRIA makes a distinction between sample values and "raw" values.
The reasoning behind this distinction is made clear in the [parameter interface](parameter_interface.md) page. If using sampled values, where values are real-valued rather than the expected integers or categoricals, then set `sampled_values` to `true` when running ADRIA.

```matlab
ai = ADRIA();

% Get details on ADRIA parameters (default values, lower/upper bounds, etc.)
parameters = ai.parameterDetails()

% ... Some sampling process ...
X = someSamplingMethod();

% `sampled_values` set to `true` as some transformation is necessary
Y = ai.run(X, sampled_values=true, nreps=50)

% Otherwise, set `sampled_values` to false
raw_values = ai.raw_defaults;
Y = ai.run(raw_values, sampled_values=false, nreps=50)
```
