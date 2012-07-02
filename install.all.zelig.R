# Install the complete Zelig software suite
#
# Installs the complete Zelig software suite (13 packages) automatically.
# It accomplishes this by:
#   * Checking the Zelig repository for existing Zelig packages
#   * Determine their dependencies without installing
#
# @author Matt Owen 
# @date 01/24/2012

start.time <- proc.time()

message("Zelig Installer v1.0")


# Repositories
cran.master <- "http://software.rc.fas.harvard.edu/mirrors/R/"
cran.master <- "http://cran.r-project.org/"

repository <- "http://r.iq.harvard.edu/"
src.contrib <- paste(repository, "src/contrib/", sep="")

# Packages to install
packages <- c(
              'Zelig', 'ZeligMisc', 'ZeligNetwork', 'ZeligMultivariate',
              'ZeligMultinomial', 'ZeligMixed', 'ZeligBayesian', 'ZeligCommon',
              'ZeligSurvey', 'ZeligOrdinal', 'ZeligGEE', 'ZeligGAM',
              'ZeligLeastSquares'
              )


# Make options here
count <- 1
menu.items <- rep(FALSE, length(packages)+1)
names(menu.items) <- c("EVERYTHING", names(menu.items))

message("The following Zelig packages are available: ")

for (pkg in packages) {
  cat(sprintf("  %2s)  %s\n", count, pkg))
  count <- count + 1
}

message("\n")

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
