<img src="ADRIA_logo.png" width=300, height=244, style="margin-left: auto; margin-right: auto;">

Repository for the development of ADRIA: Adaptive Dynamic Reef Intervention Algorithm.

## Development quickstart

1. Clone the repository
2. Open the MATLAB IDE and navigate to the repository location
3. Run the `setupADRIAProject.m` script. This should only need to be done once.
   If reopening the project (after closing MATLAB for example), simply 
   double click the "ADRIA.prj" file to reload the project.

Step 3 above informs MATLAB of the locations of the project folders,
removing the need to `cd` into specific directories to run ADRIA functions.

Example scripts are found in the `examples` directory.

These can be run directly in the command window by script name:

```matlab
>> single_scenario
```

## Documentation

ADRIA documentation can be found under `docs/book` as a web-based manual.
Open `index.html` with any web browser.

## Tests

Tests can be run with the following in the command window:

```matlab
>> runtests("tests")
```

The argument `"tests"` in the above refers to the `tests` directory, where software tests are kept.
