# connect -----
if(create.outcome.cohorts!=FALSE){
 conn <- connect(connectionDetails)
}

# instantiate outcome cohorts -----
cohort.sql<-list.files(here("1_InstantiateCohorts","OutcomeCohorts", "sql"))
cohort.sql<-cohort.sql[cohort.sql!="CreateCohortTable.sql"]
outcome.cohorts<-tibble(id=as.integer(1:length(cohort.sql)),
                        file=cohort.sql,
                        name=str_replace(cohort.sql, ".sql", ""))

if(create.outcome.cohorts==TRUE){
print(paste0("- Getting outcome cohorts"))
info(logger, "- Getting outcome cohorts")

# create empty cohorts table
sql<-readSql(here("1_InstantiateCohorts","OutcomeCohorts","sql","CreateCohortTable.sql"))
sql<-SqlRender::translate(sql, targetDialect = targetDialect)
renderTranslateExecuteSql(conn=conn, 
                          sql,
                          cohort_database_schema =  results_database_schema,
                          cohort_table = cohortTableOutcomes)
rm(sql)

for(cohort.i in 1:length(outcome.cohorts$id)){
  working.id<-outcome.cohorts$id[cohort.i]
  print(paste0("-- Getting: ",  outcome.cohorts$name[cohort.i],
               " (", cohort.i, " of ", length(outcome.cohorts$name), ")"))
  info(logger, paste0("-- Getting: ",  outcome.cohorts$name[cohort.i],
               " (", cohort.i, " of ", length(outcome.cohorts$name), ")"))
  
  sql<-readSql(here("1_InstantiateCohorts","OutcomeCohorts", "sql",outcome.cohorts$file[cohort.i])) 
  sql <- sub("BEGIN: Inclusion Impact Analysis - event.*END: Inclusion Impact Analysis - person", "", sql)
  sql<-SqlRender::translate(sql, targetDialect = targetDialect)
  renderTranslateExecuteSql(conn=conn, 
                            sql, 
                            cdm_database_schema = cdm_database_schema,
                            vocabulary_database_schema = vocabulary_database_schema,
                            target_database_schema = results_database_schema,
                            # results_database_schema = results_database_schema,
                            target_cohort_table = cohortTableOutcomes,
                            target_cohort_id = working.id)  
}
} else {
  print(paste0("Skipping creating outcome cohorts"))
  info(logger, "Skipping creating outcome cohorts")

}

# link to table
outcome.cohorts_db<-tbl(db, sql(paste0("SELECT * FROM ",
                                        results_database_schema,".",
                                        cohortTableOutcomes)))%>% 
  mutate(cohort_definition_id=as.integer(cohort_definition_id)) 

# disconnect ----
if(create.outcome.cohorts!=FALSE){
disconnect(conn)
}
