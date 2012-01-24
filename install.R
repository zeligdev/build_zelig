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
repository <- "http://140.247.114.117/~matt/src/contrib/"

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
package.matrix <- available.packages(repository, fields="Depends")
package.matrix <- tools::package.dependencies(package.matrix)



# Dependencies for each package
package.dependencies <- Map(
                            function (pkg) pkg[, 1],
                            package.matrix
                            )


for (pkg in names(package.dependencies)) {
  deps <- package.dependencies[[pkg]]

  for (pkg.dep in deps) {
    print(pkg.dep)
  }
  cat("\n")
}

q()






# This package comes with source distributions
install.packages('methods', repos=cran.master) # methods comes bundled with R

# These packages come bundled with binary distributions
install.packages('survival', repos=cran.master)
install.packages('MASS', repos=cran.master)



#
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
