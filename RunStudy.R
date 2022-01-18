# if you have already created the cohorts, you can set this to FALSE to skip instantiating these cohorts again
create.outcome.cohorts<-TRUE

if (!file.exists(output.folder)){
  dir.create(output.folder, recursive = TRUE)}

start<-Sys.time()
# start log ----
log_file <- paste0(output.folder, "/log.txt")
logger <- create.logger()
logfile(logger) <- log_file
level(logger) <- "INFO"

# result table names ----
cohortTableOutcomes<-paste0(cohortTableStem, "Outcomes")

# instantiate study cohorts ----
info(logger, 'INSTANTIATING STUDY COHORTS')
source(here("1_InstantiateCohorts","InstantiateStudyCohorts.R"))
info(logger, 'GOT STUDY COHORTS')

# Run analysis ----
info(logger, 'RUNNING ANALYSIS')
source(here("2_Analysis","Analysis.R"))
info(logger, 'ANALYSIS RAN')

# Tidy up and save ----
write.csv(outcome.cohort.counts,
          file = paste0(output.folder, "/cohort.counts_", db.name, ".csv"))
write.csv(outcome.summary,
          file = paste0(output.folder, "/summary_", db.name, ".csv"))

# Time taken
x <- abs(as.numeric(Sys.time()-start, units="secs"))
info(logger, paste0("Study took: ", 
                    sprintf("%02d:%02d:%02d:%02d", 
                            x %/% 86400,  x %% 86400 %/% 3600, x %% 3600 %/% 
                              60,  x %% 60 %/% 1)))

# # zip results
print("Zipping results to output folder")
unlink(paste0(output.folder, "/OutputToShare_", db.name, ".zip"))
zipName <- paste0(output.folder, "/OutputToShare_", db.name, ".zip")

files<-c(log_file,
         paste0(output.folder, "/cohort.counts_", db.name, ".csv"),
         paste0(output.folder, "/summary_", db.name, ".csv"))
files <- files[file.exists(files)==TRUE]
createZipFile(zipFile = zipName,
              rootFolder=output.folder,
              files = files)

print("Done!")
print("-- If all has worked, there should now be a zip folder with your results in the output folder to share")
print("-- Thank you for running the study!")
Sys.time()-start
# readLines(log_file)

