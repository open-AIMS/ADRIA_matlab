# Development setup

The initial steps to setting up a development environment are to:

1. Clone the repository
2. Open the MATLAB IDE and navigate to the repository location
3. Run the `setupADRIAProject.m` script. This should only need to be done once (see note below).
   If reopening the project (after closing MATLAB for example), simply 
   double click the "ADRIA.prj" file to reload the project.

Step 3 above informs MATLAB of the locations of the project folders,
removing the need to `cd` into specific directories to run ADRIA functions.

**Note:**

ADRIA is under constant and rapid development. Some changes will require the project to be rebuilt.

In such cases, delete the `ADRIA.prj` file and the `resources` directory,
and rerun `setupADRIAProject.m`


## Install Toolboxes

The following toolboxes are required:
- Statistics and Machine Learning Toolbox
- Parallel Computing Toolbox
- Global Optimization Toolbox

An example run script (`examples/single_scenario.m`) can be run by calling 

```matlab
>> single_scenario
```

in the command window. 

The example will produce a plot of example results.


### Tests

Tests can be run with the following in the command window:

```matlab
>> runtests('tests')
```

ADRIA has been confirmed to run on MATLAB R2021a and R2019b.

# Project structure

ADRIA consists of the following directories:

- ADRIAfunctions : files defining ADRIA functions
- ADRIAmain : main program files for ADRIA
- docs : documentation files (this document)
- examples : Set of examples showcasing programmatic use of ADRIA
- Inputs : set of input files (mostly for example purposes)
- Outputs : example results are stored here
- tests : software tests for ADRIA (see [Tests](#tests) section above)




