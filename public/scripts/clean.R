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
student_details$act_score |> quantile(seq(0, 1, .25), na.rm = T) -> x
student_details$act_score <- student_details$act_score |> cut(x) |> as.character()
student_details$act_score[which(is.na(student_details$act_score))] <- "No Score"
student_details$act_score <- student_details$act_score |> factor(levels = c("No Score", "(13,21]",  "(21,23]",  "(23,26]",  "(26,35]"))

student_details$hs_gpa_entry |> quantile(seq(0, 1, .25), na.rm = T) -> x
student_details$hs_gpa_entry <- student_details$hs_gpa_entry |> cut(x) |> as.character()
student_details$hs_gpa_entry[which(is.na(student_details$hs_gpa_entry))] <- "No Score"
student_details$hs_gpa_entry <- student_details$hs_gpa_entry |> factor(levels = c("No Score", "(1.49,3.19]", "(3.19,3.5]", "(3.5,3.82]", "(3.82,6.99]"))
