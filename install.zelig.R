# Install the complete Zelig software suite
#
# Installs the complete Zelig software suite (13 packages) automatically.
# It accomplishes this by:
#   * Checking the Zelig repository for existing Zelig packages
#   * Determine their dependencies without installing
#
# @author Matt Owen 
# @date 01/24/2012

# Get start time, so that we can compute elapsed later
start.time <- proc.time()

#
message("+----------------------+")
message("| Zelig Installer v1.0 |")
message("|                      |")
message("| List and install all |")
message("|  All Zelig packages  |")
message("+----------------------+")
message("\n")


# CRAN Repository
cran.master <- "http://cran.r-project.org/"

# IQSS Repository
repository <- "http://r.iq.harvard.edu/"
src.contrib <- paste(repository, "src/contrib/", sep="")


# Complete list of Zelig packages
packages <- c(
              'Zelig', 'ZeligMisc', 'ZeligNetwork', 'ZeligMultivariate',
              'ZeligMultinomial', 'ZeligMixed', 'ZeligBayesian', 'ZeligCommon',
              'ZeligSurvey', 'ZeligOrdinal', 'ZeligGEE', 'ZeligGAM',
              'ZeligLeastSquares'
              )


# Make options here
count <- 1
menu.items <- c(TRUE, rep(FALSE, length(packages)))
names(menu.items) <- c("EVERYTHING", packages)

message("The following Zelig packages are available: ")


# Choose the type of installation
#
# Queries the use on whether they would like to install everything, perform
# an interactive custom install, or quit.
choose.setup <- (function () {

  # 
  menu.items <- c(
                  "Install All Packages [Recommended]",
                  "Custom Install",
                  "Quit"
                  )

  #
  function () {
    res <- menu(menu.items)

    if (res == 3)
      q()

    res
  }
})()



# Choose the packages to install
#
#
choose.packages <- (function () {

  # Create a menu with 
  menu.items <- rep(FALSE, length(packages)-1)
  names(menu.items) <- packages[-1]

  descr <- c(
    # Zelig = "The core Zelig package",
    ZeligMisc = "Miscellaneous",
    ZeligLeastSquares = "Multi-stage least squares regressions",
    ZeligSurvey = "Survey-weighted regressions",
    ZeligGEE = "General Estimating Equation (GEE) Models",
    ZeligGAM = "General Additive Models (GAM)",
    ZeligNetwork = "Social Network Regressions",
    ZeligBayesian = "Bayesian general linear models",
    ZeligMultivariate = "Multivariate regressions",
    ZeligMultinomial = 
      "Regressions for simulating multinomial nominal and categorical data",
    ZeligMixed = "Multilevel regressions",
    ZeligOrdinal = "Methods for simulating ordinal data",
    ZeligCommon = "Common regressions"
    )

  # 
  menu.items <- menu.items[sort(names(descr))]
  descr <- descr[sort(names(descr))]

  function () {

    # If there is a mismatch between menu.items and descr, then 
    if (length(menu.items) != length(descr))
      stop("Installation script failed.")

    res <- -1

    while (res != 0) {
      # Use selections to paste asterisks to the front of the menu items
      blurbs <- Map(function (x) ifelse(x, "* ", ""), menu.items)
      blurbs <- paste(blurbs, names(descr), ": ", descr, sep ="")

      # Helpful message
      message("Please make a selection. \"0\" installs your selections.")
      message()
      message("Asterisks (*) indicate the package is set to be installed.")

      # Display the menu
      res <- menu(blurbs)

      # Invert the selection for what was chosen
      menu.items[res] <- !menu.items[res]
      
      message("\n\n\n\n\n")
      cat("Note: Your current selection of packages is:\n")

      # Format the selections
      selections <- names(Filter(function (x) x, menu.items))
      selections.str <- paste(paste(" -->", selections), collapse = "\n")

      # Display the selections
      message(selections.str, "\n\n")
    }


    c("Zelig", names(Filter(function (x) x, menu.items)))
  }
})()



response <- choose.setup()

# If response is "CUSTOM INSTALL"
if (response == 2)
  # This specifies the list of appropriate packages
  packages <- choose.packages()

# Else... install everything


# PROGRAM START

message("\n\n\n\nPackage Installation Start")

# Ensure that all the packages are unique, and that they are appropriately named
packages <- unique(packages)
names(packages) <- packages


# Specify which packages are being installed
cat("\nThe following packages of the Zelig suite will be installed:\n")

message(paste(paste(" -->", packages), collapse = "\n"))


# Extract dependency information on all packages in the repository
package.matrix <- available.packages(src.contrib, fields="Depends")
package.matrix <- tools::package.dependencies(package.matrix)
package.matrix <- package.matrix[ ! is.na(package.matrix) ]
package.matrix <- package.matrix[packages]
package.dependencies <- Map(
                            function (pkg) { pkg[, 1] },
                            package.matrix
                            )


# Tell user which packages are being install from CRAN
cat("\nThe following are the package dependencies \n")

# List all the dependencies required to be installed from CRAN
for (pkg.name in names(package.dependencies)) {
  # Get dependencies for each package (sans version number)
  pkg.deps <- package.dependencies[[pkg.name]]

  # Collapse character vector into a single string
  pkg.deps <- paste(pkg.deps, collapse = ", ")

  # Output as a message
  message(sprintf(" --> %s requires: %s", pkg.name, pkg.deps))
}

message("\n")

package.dependencies <- unique(unlist(package.dependencies))
package.dependencies <- package.dependencies['R' != package.dependencies]
package.dependencies <- package.dependencies['Zelig' != package.dependencies]


# List all the dependencies required individually
message("The following dependencies will be installed from CRAN")
message(paste(paste(" -->", package.dependencies), collapse = "\n"))

# Output message
cat("\nEnsuring that several important packages are installed...\n")

message("\n")


# This package comes with source distributions
# methods comes bundled with R
message("Installing 'methods'")
install.packages('methods', repos=cran.master, quiet = TRUE)

message("\n")


# These packages come bundled with binary distributions
message("Installing 'survival'...")
install.packages('survival', repos=cran.master, quiet = TRUE)

message("\n")


message("Installing 'MASS'...")
install.packages('MASS', repos=cran.master, quiet = TRUE)

message("\n\n")


# Install all the dependency packages from CRAN

message("Installing dependency packages from CRAN")

for (pkg in package.dependencies)
  install.packages(pkg, repos = cran.master)

message("\n\n")


# Initialize fails and successes as zero
fails <- successes <- c()

message("Installing Zelig packages\n")

for (pkg in packages) {
  message("Installing ", pkg)
  res <- tryCatch(
                  {
                    install.packages(pkg, repos=repository, type='source');
                    TRUE
                  },
                  warning = function (w) {
                    print(w)
                    q()
                    FALSE
                  },
                  error = function (e) FALSE
                  )
  message("\n")

  if (res)
    successes <- c(successes, pkg)

  else
    fails <- c(fails, pkg)
}

message("\n\n")


# Output success
if (length(successes)) {
  message("The folowing packages have been successfully installed:")
  message(paste(paste(successes, sep = " * "), collapse = "\n"))
  message("\n")
}


if (length(fails)) {
  cat("The following packages were not installed:\n")
  cat(paste(paste(fails, sep = " * "), collapse = "\n"))
  message("\n")
}


dur <- round((proc.time() - start.time)[["elapsed"]])

cat(sprintf("Elapsed time: %d:%d", trunc(dur/60), dur %% 60), "\n")
