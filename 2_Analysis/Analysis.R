# get counts ----
outcome.cohort.counts<-outcome.cohorts %>% 
  left_join(outcome.cohorts_db %>% 
               group_by(cohort_definition_id) %>% 
               tally() %>% 
               collect()  %>% 
               select(cohort_definition_id, n),
             by=c("id"="cohort_definition_id")) 
outcome.cohort.counts$n<-as.numeric(outcome.cohort.counts$n)
outcome.cohort.counts$n<-ifelse(is.na(outcome.cohort.counts$n), 0, outcome.cohort.counts$n)
outcome.cohort.counts$db<-db.name


# summarise ----
outcome.names<-outcome.cohorts$name
outcome.names<-str_replace(outcome.names, "_platelet_meas", "")
outcome.names<-str_replace(outcome.names, "_TTS_meas_only", "")
outcome.names<-unique(outcome.names)

outcome.summary<-list()
for(i in 1:length(outcome.names) ){
n.tot<-outcome.cohort.counts %>% 
  filter(outcome.cohort.counts$name==outcome.names[i]) %>% 
  select(n) %>%  pull()
n.pl_measured<-outcome.cohort.counts %>% 
  filter(outcome.cohort.counts$name==
           paste0(outcome.names[i], "_platelet_meas", "")) %>% 
  select(n) %>%  pull()
n.thrombocyt<-outcome.cohort.counts %>% 
  filter(outcome.cohort.counts$name==
           paste0(outcome.names[i], "_TTS_meas_only", "")) %>% 
  select(n) %>%  pull()

outcome.summary[[i]] <- data.frame(
  db=db.name,
  event=outcome.names[i],
  total=n.tot,
  platelets.measured=n.pl_measured,
  prop.platelets.measured=n.pl_measured/n.tot,
  thrombocytopenia=n.thrombocyt,
  prop.thrombocytopenia.of.total=n.thrombocyt/n.tot,
  prop.thrombocytopenia.of.measured=n.thrombocyt/n.pl_measured)
}
outcome.summary<-bind_rows(outcome.summary)
