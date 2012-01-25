# Install the complete Zelig software suite
#
# Installs the complete Zelig software suite (13 packages) automatically.
# It accomplishes this by:
#   * Checking the Zelig repository for existing Zelig packages
#   * Determine their dependencies without installing
#
# @author Matt Owen 
# @date 01/24/2012



# Repositories
cran.master <- "http://software.rc.fas.harvard.edu/mirrors/R/"
cran.master <- "http://cran.r-project.org/"

repository <- "http://140.247.114.117/~matt/"
src.contrib <- "http://140.247.114.117/~matt/src/contrib/"

# Packages to install
packages <- c(
              'Zelig',
              'ZeligMisc',
              'ZeligNetwork',
              'ZeligMultivariate',
              'ZeligMultinomial',
              'ZeligMixed',
              'ZeligBayesian',
              'ZeligCommon',
              'ZeligSurvey',
              'ZeligOrdinal',
              'ZeligGEE',
              'ZeligGAM',
              'ZeligLeastSquares'
              )

packages <- unique(packages)
names(packages) <- packages

# Information on all available packages
package.matrix <- available.packages(src.contrib, fields="Depends")
package.matrix <- tools::package.dependencies(package.matrix)

# All available



# Dependencies for each package
package.dependencies <- Map(
                            function (pkg) pkg[, 1],
                            package.matrix
                            )
package.dependencies <- unique(unlist(package.dependencies))
package.dependencies <- package.dependencies['R' != package.dependencies]


# This package comes with source distributions
install.packages('methods', repos=cran.master) # methods comes bundled with R

# These packages come bundled with binary distributions
install.packages('survival', repos=cran.master)
install.packages('MASS', repos=cran.master)

# Install all the dependency packages from CRAN
for (pkg in names(package.dependencies))
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
cat("The folowing packages have been successfully installed:\n")
cat(paste(paste(successes, sep = " * "), collapse = "\n"))

cat("\n\n")
cat("The following packages were not installed:\n")
cat(paste(paste(fails, sep = " * "), collapse = "\n"))
