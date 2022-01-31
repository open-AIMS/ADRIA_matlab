# Documentation Build Process

The ADRIA documentation (this document/website) is generated from a collection of files in [markdown format](https://www.markdownguide.org/).
These files live inside the `docs` folder in the project repository.

The documentation website is generated with [mdBook](https://github.com/rust-lang/mdBook), a standalone application written in the rust programming language. `mdBook` is configured to run via [GitHub Actions](https://github.com/features/actions) on any commit that changes the `docs` folder on the `main` branch. The file which specifies the build action resides in `.github/workflows/build-docs.yaml`.

## (Why we're not building) Documentation from docstrings

Currently relevant portions of docstrings are manually copy/pasted into the `concise API` section.
Although there are tools available to generate documentation directly from docstrings, these typically require an additional platform or language to be configured

Although there are tools available to generate documentation directly from docstrings, these typically require an additional platform or language to be installed and set up.
The most relevant MATLAB-specific tool is [m2docgen](https://au.mathworks.com/matlabcentral/fileexchange/96289-m2docgen?requestedDomain=), which looks promising. It does, however, require substantial rewrite of existing docstrings to conform with the expected style.
