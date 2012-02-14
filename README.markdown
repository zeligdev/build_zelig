#Zelig Build Manages Zelig-Add-ons
This tool is used internally by the SWaP team at IQSS Harvard University to 
manage the building of statistical packages.

##Instructions
1. Clone this repository
2. Run: ```python pkg-build -h``` for help instructions and syntax explanation
3. Run: ```python pkg-build -d <DIRECTORY_NAME>``` to clone, check and build the repository within ```<DIRECTORY_NAME>```
4. Run: ```pythong pkg-build -d <DIRECTORY_NAME> <PKG_TITLE>``` to clone, check and build the package titled ```<PKG_TITLE>``` within the repository ```<DIRECTORY_NAME>```

##Manifest
* ```pkg-build```: build packages from the Git user found at: https://github.com/zeligdev
* ```pkg-update```: shell script which behave similarly to ```pkg-build```. This script is deprecated. Related files are:
* ```REPOSITORIES```: list of repositories to extract from. This is not used by ```pkg-build``` as it currently uses the GitHub API
* ```sweave```: a script used to convert ```Rnw``` documents (typical in R packages) to ```PDF``` documents
* ```install.R```: install script used to install every Zelig packages. Available here: http://r.iq.harvard.edu/install.R
* ```install_custom.R```: install wizard used to guide new users through the Zelig installation procedure. Available here: http://r.iq.harvard.edu/install_live.R
* ```simple_json```: a python module used to parse JSON responses. This is used by ```pkg-build``` to get the most recent versions of Zelig packages
