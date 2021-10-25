# Development setup

The initial steps to setting up a development environment are to:

1. Clone the repository
2. Open the MATLAB IDE and navigate to the repository location
3. Run the `setupADRIAProject.m` script. This should only need to be done once.
   If reopening the project (after closing MATLAB for example), simply 
   double click the "ADRIA.prj" file to reload the project.

Step 3 above informs MATLAB of the locations of the project folders,
removing the need to `cd` into specific directories to run ADRIA functions.

An example run script (`examples/run_example.m`) can be run by calling 

```matlab
>> run_example
```

in the command window. 

The example will produce results in the specified outputs directory.

An ADRIA app can also be started by running `ADRIAv1.mlapp`

### Tests

Tests can be run with the following in the command window:

```matlab
>> cd tests
>> runtests
```

