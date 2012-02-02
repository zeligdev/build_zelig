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
    Zelig = "The core Zelig package",
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


  function () {

    # print(paste(descr[packages], " (", packages, ")", sep=""))

    res <- -1

    while (res != 0) {
      message("Please make a selection. `0' installs the your selections")
      res <- menu(c(names(menu.items)))

      menu.items[res] <- !menu.items[res]
      
      message("\n\n\n\n\n")
      message("The following packages will be installed: ")
      cat(paste(names(Filter(function (x) x, menu.items)), sep=", "))
      cat("\n\n")
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

packages <- unique(packages)
names(packages) <- packages

# Information on all available packages
package.matrix <- available.packages(src.contrib, fields="Depends")
package.matrix <- tools::package.dependencies(package.matrix)
package.matrix <- package.matrix[ ! is.na(package.matrix) ]
package.matrix <- package.matrix[packages]
package.dependencies <- Map(
                            function (pkg) { pkg[, 1] },
                            package.matrix
                            )

message("Dependencies (by package):")

for (pkg.name in names(package.dependencies)) {
  pkg.deps <- package.dependencies[[pkg.name]]
  pkg.deps <- paste(pkg.deps, collapse = ", ")

  cat(sprintf(" * %s (%s)", pkg.deps, pkg.name), "\n")
}

message("\n")

package.dependencies <- unique(unlist(package.dependencies))
package.dependencies <- package.dependencies['R' != package.dependencies]
package.dependencies <- package.dependencies['Zelig' != package.dependencies]


message("The following dependencies will be installed from CRAN")
message(paste(paste(" *", package.dependencies), collapse = "\n"))
message("\n\n")

# This package comes with source distributions
# methods comes bundled with R
install.packages('methods', repos=cran.master, quiet = TRUE)

# These packages come bundled with binary distributions
install.packages('survival', repos=cran.master, quiet = TRUE)
install.packages('MASS', repos=cran.master, quiet = TRUE)

# Install all the dependency packages from CRAN
for (pkg in package.dependencies)
  install.packages(pkg, repos = cran.master)

# Initialize fails and successes as zero
fails <- successes <- c()

for (pkg in packages) {
  res <- tryCatch(
                  {
                    install.packages(pkg, repos=repository, type='source');
                    TRUE
                  },
                  warning = function (w) FALSE,
                  error = function (e) FALSE
                  )

  if (res)
    successes <- c(successes, pkg)

  else
    fails <- c(fails, pkg)
}



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
