ADRIA contains functions to collate parameter values and details on a component-level basis.

Parameters of interest are currently grouped over four components:

1. Intervention Options
2. Decision maker preferences (criteria weights)
3. Core ADRIA parameters (under development)
4. Ecological parameters (under development)

Functions for each group of parameters use the suffix `Details`:

- interventionDetails()
- criteriaDetails()
- coreParamDetails()
- ecolParamDetails()

Usage of these functions are identical.

Approaches to explore model behavior requires parameters, their bounds, and likely "default" values to be provided and defined.
A wide number of software is available to sample from these value ranges, using expected or known distributions. A more recent
but still not widely considered aspect, are the correlations between parameters. Sampling these parameters is a common activity
across all model exploration approaches.

One complication is that these sampling methods and tooling expect real parameter values (e.g., xᵢ ∈ ℝ), represented in a
single "flat" data structure (e.g., a table). Environmental models and decision support tools on the other hand can be designed
to accept whole number (integers) or categorical values. These may indicate a specific simulation context (RCP scenario),
environmental scenario (climate sequences, data held in raster format, etc), and such "scenario configuration" may be held
in a nested data structure. It is therefore necessary to have a process that is able to pass parameter values from ADRIA
into samplers for the purpose of sensitivity analysis, uncertainty propagation, optimization and other Monte Carlo or
probabilistic processes.

To support this activity, the functions listed above provides a table of parameter details consisting of:

- `name` holds the parameter names
- `ptype` denotes the parameter type (`categorical`, `integer`, or `float`)
- `defaults` indicates the raw unmodified assigned value
- `lower_bound`, discrete min/max values for sampling purposes
- `upper_bound`
- `options`, column of hashmaps ([`Map Containers`](https://au.mathworks.com/help/matlab/map-containers.html) in MATLAB) which maps possible discrete values back to their categorical options, or NaN if not applicable)
- `raw_lower_bound` ('raw' min/max of option values indicating their original ADRIA value ranges)
- `raw_upper_bound`

[TODO: Description of each entry - could be useful if tooltips are to be incorporated into UIs]

```matlab
>> interv_opts = interventionDetails()

interv_opts =

  9×8 table

       name           ptype        sample_defaults    lower_bound     upper_bound       options       raw_defaults        raw_bounds    
    __________    _____________    _______________    ___________    ______________    __________    ______________    _________________

    "Guided"      "categorical"    {[         1]}     {[     1]}     {[         3]}    {1×1 cell}    {[         0]}    {[          0 1]}
    "PrSites"     "integer"        {[         3]}     {[     1]}     {[         4]}    {1×1 cell}    {[         3]}    {[          1 3]}
    "Seed1"       "float"          {[5.0000e-04]}     {[     0]}     {[1.0000e-03]}    {[   NaN]}    {[5.0000e-04]}    {[ 0 1.0000e-03]}
    "Seed2"       "float"          {[         0]}     {[     0]}     {[         1]}    {[   NaN]}    {[         0]}    {[          0 1]}
    "SRM"         "categorical"    {[         1]}     {[     1]}     {[         3]}    {1×1 cell}    {[         0]}    {[          0 1]}
    "Aadpt"       "integer"        {[         1]}     {[     1]}     {[         8]}    {1×1 cell}    {[         6]}    {[         6 12]}
    "Natad"       "float"          {[    0.0500]}     {[0.0100]}     {[    0.1000]}    {[   NaN]}    {[    0.0500]}    {[0.0100 0.1000]}
    "Seedyrs"     "integer"        {[         1]}     {[     1]}     {[         7]}    {1×1 cell}    {[        10]}    {[        10 15]}
    "Shadeyrs"    "integer"        {[         1]}     {[     1]}     {[         6]}    {1×1 cell}    {[         1]}    {[          1 5]}
```

For Monte Carlo approaches, the typical process is:

1. Generate $N$ samples using the indicated bounds from `lower_bounds` and `upper_bounds`
2. Pass sampled values into a wrapper/interface function
3. The interface function in Step 2 translates/maps the sampled values back to the values expected by ADRIA.
4. Run ADRIA with those "translated" values

The translation of sampled values to the so-called "ADRIA values" for integer and categorical parameters relies on the "flooring trick".

To illustrate the approach, take a parameter $x_i$ that can take the form of discrete values between 1 and 3 (inclusive). In other words, there are 3 valid options to take: 1, 2, 3.

1. The `upper_bound` value becomes $\text{max}(x_i) + \text{min}(x_i)$ (i.e., 4)
2. Sample from this range usual a given sampler, which returns a value $v_i$; $1 \leq v_i \lt 4$, where $v_i \in \reals$
3. Take the `floor` of $v_i$. If $v_i = 3.9$, then $\text{floor}(v_i) = 3$.

For `categorical` parameters, an extra step is to extract the corresponding `Map Container` from the `options` column and use the floored value as the key to obtain the categorical value.

As an example, $x_i$ may in fact represent "high", "medium", "low" (i.e., ADRIA expects a string input) and
so the relationship between sampled and ADRIA values becomes:

- `1 => "high"`
- `2 => "medium"`
- `3 => "low"`

and this relationship is encapsulated by the `Map Container`.

For `integer` parameters, the same process above may be used. In some cases, however, the options may be represented in an array of valid options
in which case the index of the matching value is used:

```matlab
   name           ptype        sample_defaults    lower_bound     upper_bound       options       raw_defaults        raw_bounds    
   __________    _____________    _______________    ___________    ______________    __________    ______________    _________________
   "Seedyrs"     "integer"        {[         1]}     {[     1]}     {[         7]}    {1×1 cell}    {[        10]}    {[        10 15]}
```

In the above, the "true" bounds of values are between 10 to 15 (so six entries: 10, 11, 12, 13, 14, 15).
In other cases, these may be arrays (e.g., `[[0,1], [1,2], [2,1]]`).

The sample bounds for `integer` parameters are tied to the number of options rather than their values.
This is the conversion approach is generic and applicable to both cases outlined above.

Following the $\text{max}(x_i) + \text{min}(x_i)$ approach, the sample range becomes $1 \leq v_i \lt 7$.
In the first example above, `1 => 10` and $\text{floor}(6.999) = 6$, and resolves to `6 => 15`.

If the "true" default value is 10, then this is mapped to the first entry in the array, thus the `sample_defaults` value is set to 1 (as shown in the table snippet above).

The process described above is conducted by the `convertScenarioSelection()` function, which takes two inputs: (1) an array of sampled values, and (2) the parameter details table.

The only requirement is that the the number and order of items in the sample array has to match what is 
defined in the table. By satisficing this requirement, any subset of parameters can be used.

The following snippet is illustrative only, and should not be expected to work.
Its only intention is to highlight usage of the `*Details()` group of functions in combination with `convertScenarioSelection()`.

```matlab
function Y = someObjectiveFunc(sampled_x, param_details)
    % Convert sampled values back to "ADRIA expected" values
    interv_x = convertScenarioSelection(sampled_x, param_details);

    % Run a single simulation/scenario
    intermediate = runADRIAScenario(interv_x, [... other parameters considered constant for this example ...]);

    Y = some_processing(intermediate); % e.g., calculate a metric or extract averages...
end


% Collect details of intervention parameters
interv_opts = interventionDetails();

% Parameter details can be collated into a single table
% like so:
% [interventionDetails(); criteriaDetails()]

% Extract names of each intervention parameter
interv_names = interv_opts.name;

% Use defaults as the initial best guess
x0 = interv_opts.sample_defaults;

% Retrieve the bounds for sampling purposes for each parameter
lb = interv_opts.lower_bounds;
ub = interv_opts.upper_bounds;

objfunc = @(x) someObjectiveFunc(x, interv_opts);

% Begin optimisation (only run for 30 seconds)
obj_opts = optimoptions('simulannealbnd', 'MaxTime', 30);
x = simulannealbnd(objfunc, x0, lb, ub, obj_opts);
```