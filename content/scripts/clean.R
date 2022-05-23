library(data.table)
library(ggplot2)



raw_data <- lapply(list.files("/home/kent/Documents/oushowcase/content/data"), \(i) {
  if (!grepl(".csv", i)) return()
  nm = gsub(".csv", "", i) 
  fread(paste0("/home/kent/Documents/oushowcase/content/data/",i)) |> 
    janitor::clean_names()
})

names(raw_data) <- sapply(list.files("/home/kent/Documents/oushowcase/content/data"), \(i) {
  if (!grepl(".csv", i)) return()
  nm = gsub(".csv", "", i)
  nm}
)

for (i in list.files("/home/kent/Documents/oushowcase/content/data")) {
  if (!grepl(".csv", i)) return()
  nm = gsub(".csv", "", i) 
  assign(nm, fread(paste0("/home/kent/Documents/oushowcase/content/data/",i)) |> 
           janitor::clean_names()
  )
}


# Course Enrollments ------------------------------------------------------

#define success
course_enrollments[,success := grepl("A|B|C(?!\\-)", official_grade, perl = T) & 
                     completed_flag == 1 & official_grade != "NC"]
# create ordered (somewhat) factor for grades
course_enrollments$official_grade <- ordered(course_enrollments$official_grade, levels = c("A", "A-", "B+", "B", "B-", "C+", "C", "C-", "D+", "D", "D-", 
                                                                                           "DROP", "F", "FN", "FS", "I", "NC", "S", "W", "WF", "WN", "WP"))

student_details[,hardship_score := as.factor(hardship_score)]

student_details[,act_score_resp := !is.na(act_score)]
student_details$act_score |> quantile(seq(0, 1, .25), na.rm = T) -> x
student_details$act_score_factor <- student_details$act_score |> cut(x, include.lowest = F) |> as.character()
student_details$act_score_factor[which(is.na(student_details$act_score_factor))] <- "No Score"
student_details$act_score_factor <- student_details$act_score_factor |> 
  factor(levels = c("No Score", unique(student_details$act_score_factor) |> 
                      sort() |> {\(x) x[which(x != "No Score")]}()))

student_details[,hs_gpa_entry_resp := !is.na(hs_gpa_entry)]
student_details$hs_gpa_entry |> quantile(seq(0, 1, .25), na.rm = T) -> x
student_details$hs_gpa_entry_factor <- student_details$hs_gpa_entry |> cut(x, include.lowest = F) |> as.character()
student_details$hs_gpa_entry_factor[which(is.na(student_details$hs_gpa_entry))] <- "No Score"
student_details$hs_gpa_entry_factor <- student_details$hs_gpa_entry_factor |> 
  factor(levels = c("No Score", unique(student_details$hs_gpa_entry_factor) |> 
                      sort() |> {\(x) x[which(x != "No Score")]}()))
