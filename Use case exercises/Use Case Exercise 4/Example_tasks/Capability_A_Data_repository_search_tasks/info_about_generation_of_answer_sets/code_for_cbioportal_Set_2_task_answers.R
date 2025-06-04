library(cbioportalR)
library(dplyr)
library(stringr)

setwd("C:/Users/tkorves/Desktop/new cbioportal tasks")

set_cbioportal_db("public")

#SET DIRECTORY FOR FILES


# cBioPortal Task 1
# ques: From cBioPortal, download information about available studies with data from patients with lung adenocarcinoma patients in the TCGA study.
# ques_dialog_version: What research studies are available in cBioPortal about lung adenocarcinoma patients in the TCGA study?
# query_information: Query for studies that have ("description" or "name" containing the text "lung adenocarcinoma" or have cancerTypeId=="luad") 
#	    and ( "tcga" in "description" or "name"). Return all study metadata.
# rubric: "luad_tcga_studies.csv" is provided with this task as the reference.

studies<-available_studies()
lung_adeno_tcga_studies<-studies[ (str_detect(tolower(studies$description), 'lung adenocarcinoma')|str_detect(tolower(studies$name), 'lung adenocarcinoma')|studies$cancerTypeId=="luad")
                             & (str_detect(tolower(studies$description), 'tcga')|str_detect(tolower(studies$name), 'tcga')),]
write.csv(lung_adeno_tcga_studies,"luad_tcga_studies.csv", row.names = FALSE)


# cBioPortal Task 2
# ques: Download a file with information about the kinds of data available in the 'luad_tcga_gdc' study, including descriptions of the datatypes.
# ques_dialog_version: Show me the kinds of data available in the 'luad_tcga_gdc' study, including descriptions of the datatypes.
# query_information: Query for available_profiles for the studyid 'luad_tcga_gdc' and return the file. 
# rubric: "luad_tcga_gdc_study_profile.csv" is provided with this task as the reference.

write.csv(available_profiles(study_id = "luad_tcga_gdc" ),"luad_tcga_gdc_study_profile.csv", row.names = FALSE)


# task cBioPortal A3
# ques: Download copy number alteration data for the 'luad_tcga_gdc' study.
# ques_dialog_version:Get CNA data for the luad_tcga_gdc study.
# query_information: Query for CNA data associated with the study id 'luad_tcga_gdc'. Return the data file.
# rubric: "CNA_luad_tcga_gdc.csv" is provided with this task as the reference.

luad_CNA_tcga_gdc<-get_cna_by_study(study_id= 'luad_tcga_gdc')
write.csv(luad_CNA_tcga_gdc, "CNA_luad_tcga_gdc.csv", row.names=FALSE)


# task cBioPortal A4
# ques: Download a file with information about the clinical features that are available for cases in the 'luad_tcga_gdc' study.
# ques_dialog_version: Show me the clinical features that are available for patients in this study.
# query_information: Query for available_clinical_attributes associated with the study 'luad_tcga_gdc'. Return the data file.
# rubric: "luad_tcga_gdc_clinical_features.csv" is provided with this task as the reference.

luad_tcga_gdc_clinical_features<-available_clinical_attributes("luad_tcga_gdc")
write.csv(luad_tcga_gdc_clinical_features,"luad_tcga_gdc_clinical_features.csv", row.names=FALSE)


# task cBioPortal A5
# ques: Download pathologic T and pathologic N data from the luad_tcga_gdc study.
# ques_dialog_version: Get pathologic T and pathologic N data for patients from this study.
# query_information: Query for clinical data by study using the study_id 'luad_tcga_gdc'. Filter the data for entries with clinicalAttributeId with values "PATH_N_STAGE" or "PATH_T_STAGE". Return this dataset.
# rubric: "patient_data_path_N_path_T.csv" is provided with this task as the reference.

patient_data<-get_clinical_by_study(study_id='luad_tcga_gdc')
patient_data_path_N_path_T<-patient_data[patient_data$clinicalAttributeId %in% c("PATH_N_STAGE","PATH_T_STAGE"),]
write.csv(patient_data_path_N_path_T, "patient_data_path_N_path_T.csv", row.names=FALSE)


# task cBioPortal A6
# ques: Find studies with tumor stage data for TCGA lung adenocarcinoma patients.
# ques_dialog_version: What TCGA study data sets of lung adenocarcinoma patients have tumor stage data?
# query_information: Start with the list of studyIds in the dataset that was the answer for cBioPortal Task A1.
#     Obtain the available clinical attributes for each of these studies and determine if they include clinicalAttributeId values that include the string "TUMOR_STAGE". 
#     Return the studyIds for which this is true.
# rubric: The studies with these ids: "luad_tcga_pub","luad_tcga", "luad_tcga_pan_can_atlas_2018".

# Notes on this code
# lung_adeno_tcga_studies comes from cBioPortal Task A1
# This code assumes that the writer has determined that "tumor stage" corresponds to the variables that contain "TUMOR_STAGE"

for (studyi in lung_adeno_tcga_studies$studyId){
  studyi_available_clinical_attributes<-available_clinical_attributes(studyi)
  ifelse(str_detect(studyi_available_clinical_attributes$clinicalAttributeId,"TUMOR_STAGE"), 
  print(studyi), print(""))
}


# task cBioPortal A7
# ques: Download a file with age at diagnosis and tumor stage data from study 'luad_tcga_pan_can_atlas_2018'.
# ques_dialog_version: Get  age at diagnosis and tumor stage data from the luad_tcga_pan_can_atlas_2018 study data.
# query_information: Obtain the clinical attributes for the study with studyid 'luad_tcga_pan_can_atlas_2018'.
#    Use the entries under 'displayName, 'description', and/or 'clinicalAttributeId' to identify the clinicalAttributeId values for age at diagnosis and tumor stage.
#    Obtain the clinical data for the study with studyID 'luad_tcga_pan_can_atlas_2018'. Filter this for the identified clinicalAttributeID values and return this dataset.
# rubric: "patient_data_age_at_diag_tumor_stage_2018.csv" is provided with this task as the reference.

clin_attributes_2018<-available_clinical_attributes('luad_tcga_pan_can_atlas_2018')
patient_data<-get_clinical_by_study(study_id='luad_tcga_pan_can_atlas_2018')
patient_data_age_at_diag_tumor_stage_2018<-patient_data[patient_data$clinicalAttributeId %in% c("AGE", "AJCC_PATHOLOGIC_TUMOR_STAGE"),]
write.csv(patient_data_age_at_diag_tumor_stage_2018, "patient_data_age_at_diag_tumor_stage_2018.csv", row.names=FALSE)


