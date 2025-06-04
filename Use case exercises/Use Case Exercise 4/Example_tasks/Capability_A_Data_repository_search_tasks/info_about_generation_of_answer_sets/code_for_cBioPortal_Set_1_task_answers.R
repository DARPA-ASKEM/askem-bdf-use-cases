### R code used to perform each search and generate the rubric datasets:

library(cbioportalR)
library(dplyr)
library(stringr)

set_cbioportal_db("public")

#cBioPortal task 1
acc_studies<-studies[(str_detect(tolower(studies$description), 'adrenocortical carcinoma')|str_detect(tolower(studies$name), 'adrenocortical carcinoma')|
                        studies$cancerTypeId=="acc" ),]
write.csv(acc_studies,"acc_studies.csv", row.names = FALSE)

#cBioPortal task 2
ccrcc_study<-studies[(str_detect(tolower(studies$description), 'renal clear cell carcinoma')|str_detect(tolower(studies$name), 'renal clear cell carcinoma')| studies$cancerTypeId=="ccrcc" ) &
                       (str_detect(tolower(studies$description), 'tcga')|str_detect(tolower(studies$name), 'tcga'))&
                       (str_detect(tolower(studies$description), 'pancancer')|str_detect(tolower(studies$name), 'pancancer')|str_detect(tolower(studies$description), 'pan-cancer')|str_detect(tolower(studies$name), 'pan-cancer')),
                     "studyId"]
length(ccrcc_study$studyId) #Confirm that length is "1", i.e., just one study fits this description.
ccrcc_tcga_pancancer_data_files_list<-available_profiles(study_id = ccrcc_study$studyId )|> pull(molecularProfileId)
write.csv(ccrcc_tcga_pancancer_data_files_list,"ccrcc_tcga_pancancer_data_files_list.csv", row.names=FALSE)                    

#cBioPortal task 3
acl_Bottomly_study<-studies[(str_detect(tolower(studies$description), 'acute myeloid leukemia')|str_detect(tolower(studies$name), 'acute myeloid leukemia')|
                               studies$cancerTypeId=="acl" ) &
                              studies$pmid== "35868306","studyId"]
acl_Bottomly_study$studyId #check contents. See that there is one real value, plus a few NAs. Use the real value in [1].
acl_Bottomly_mut_data<-get_mutations_by_study(study_id= acl_Bottomly_study$studyId[1])
write.csv(acl_Bottomly_mut_data,"acl_Bottomly_mut_data.csv",row.names=FALSE)

#cBioPortal task 4
clinical_patientIds_luad_gdc_tcga <- get_clinical_by_patient(patient_id = c("TCGA-05-4244", "TCGA-05-4249", "TCGA-05-4250", "TCGA-05-4384", "TCGA-05-3889", "TCGA-05-4390"), study_id = 'luad_tcga_gdc')
write.csv(clinical_patientIds_luad_gdc_tcga, "clinical_patientIds_luad_gdc_tcga.csv", row.names=FALSE)
