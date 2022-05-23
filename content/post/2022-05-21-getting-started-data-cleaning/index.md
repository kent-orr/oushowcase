---
title: Getting Started - Data Cleaning
author: Kent Orr
date: '2022-05-21'
slug: getting-started-data-cleaning
categories: []
tags: []
# output:
#   blogdown::html_page:
#     toc: true
---

Every data project starts with a broad overview of the information at hand and formation of research questions or business objectives. In this case the questions are conveniently provided. Below is a simple overview of the research questions and provided data sets. 


```r
library(data.table) 
library(ggplot2)

for (i in list.files("/home/kent/Documents/oushowcase/content/data")) {
  if (!grepl(".csv", i)) return()
  nm = gsub(".csv", "", i) 
  assign(nm, fread(paste0("/home/kent/Documents/oushowcase/content/data/",i)) |> 
           janitor::clean_names()
         )
}
```

## Research Questions

The state has launched the ‘Smart Start’ Program and the university is being asked to review entry level courses. The following hypotheses are to be tested:

* What are our overall success rates (C or better)?  
* What student information helps predict success in their courses?   
* Are success rates improving or getting worse?  
* Are some of their instructors better than others?  
* Does teaching frequently the course improve instructor performance over time?  

## The Data

Common keys:

Before going any further, it is plain that the data provided resembles a relational database. I want to know how the databases interact. I'll plot the common keys between tables and give a brief, single sentence overview of the content. This document will be used as a reference during investigation.


```r
lapply(c("acad_plan", "class_instructors", "class_inventory", "course_enrollments", "student_details"),
       \(x) {
         data.table(table = x, cols = names(get(x)))
       }) |>
  rbindlist() -> tables

tables[, merge(.SD, tables[,.N, cols])][,common := N>1][] |>
  ggplot(aes(x = reorder(table, -N), y = cols, fill = common, label = table)) + 
  geom_tile(color = "black") + 
  theme_bw() +
  labs(title = "Overview of Data Keys and Columns",
       x = "Tables", y = "Columns", fill = "Is A Common Key") + 
  theme(legend.position = "bottom") + 
  scale_fill_viridis_d(option = "D") 
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-1-1.png" width="672" />


### class_instructors

links instructors with a course number and term.


```r
class_instructors
```

```
##      term_code class_nbr instructor_id_number
##   1:         1      5241                  486
##   2:         1      5242                 3234
##   3:         1      5243                  486
##   4:         1      5244                 2199
##   5:         1      5245                 2199
##  ---                                         
## 678:         6     11959                 2776
## 679:         6     14107                 3075
## 680:         6     14391                  119
## 681:         6     14553                 1886
## 682:         6     14983                 2680
```

### course_enrollments

link students to specific course numbers per term, along with some metadata such as hours carried. 


```r
course_enrollments
```

```
##        student_id_number term_code class_nbr completed_flag official_grade
##     1:               150         1      9785              1              C
##     2:               150         3      5167              0           DROP
##     3:               150         3      5062              1              D
##     4:               150         4      4981              0           DROP
##     5:               150         4      4979              1             C-
##    ---                                                                    
## 16391:             83740         6      5805              1              B
## 16392:             83744         6      5806              1              S
## 16393:             83759         6      5531              0             WF
## 16394:             64514         1      6155              1              A
## 16395:             64514         3      9890              0              F
##        acad_plan hours_carried
##     1:    BS0411            11
##     2:    BS0411             9
##     3:    BS0411             9
##     4:    BS0411             8
##     5:    BS0411             8
##    ---                        
## 16391:    ND0407            16
## 16392:    ND1206            17
## 16393:    BB6126            16
## 16394:    BC5329             8
## 16395:    BC5329            17
```

### class_inventory

metadata for courses


```r
class_inventory
```

```
##      term_code semester subject catalog_nbr class_nbr class_description
##   1:         1     Fall    BIOS         101      5350     Human Anatomy
##   2:         1     Fall    SPAN         101      6171  Beginner Spanish
##   3:         1     Fall    PHYS         101     11991   General Physics
##   4:         1     Fall    PHYS         101      8405   General Physics
##   5:         1     Fall    SPAN         101      6155  Beginner Spanish
##  ---                                                                   
## 678:         6   Spring    SPAN         101     14553  Beginner Spanish
## 679:         6   Spring    SPAN         101      5517  Beginner Spanish
## 680:         6   Spring    SPAN         101     14391  Beginner Spanish
## 681:         6   Spring    SPAN         101      5613  Beginner Spanish
## 682:         6   Spring    SPAN         101      5618  Beginner Spanish
##      department_code
##   1:              21
##   2:              16
##   3:              22
##   4:              22
##   5:              16
##  ---                
## 678:              16
## 679:              16
## 680:              16
## 681:              16
## 682:              16
```

### student_details

information about a student, demographic data independent of university experience


```r
student_details
```

```
##        student_id_number act_score hs_gpa_entry hardship_score
##     1:                 1        NA           NA              0
##     2:                 2        NA           NA              0
##     3:                 3        NA        1.030              0
##     4:                 4        NA           NA              0
##     5:                 5        NA           NA              0
##    ---                                                        
## 97108:             97108        28        4.204              0
## 97109:             97109        26        3.906              0
## 97110:             97110        26        3.055              0
## 97111:             97111        18        3.368              0
## 97112:             97112        25        4.045              0
```

### acad_plan

metadata on various academic plans


```r
acad_plan
```

```
##       acad_plan                 acad_plan_desc acad_career   degree college
##    1:    MS8894            Textiles & Clothing        GRAD    MSHCS     HSP
##    2:    CTCBIG           Conservation Biology        GRAD              A&S
##    3:    CTDIAG                       Diabetes        GRAD              HSP
##    4:    CTNEDG    Post-Masters Nurse Educator        GRAD              HSP
##    5:    DP8140               Physical Therapy        GRAD      DPT     HSP
##   ---                                                                      
## 2687:    CTHRMG     Human Resources Management        GRAD    CERTG     COB
## 2688:    CTSSLG Strategic Selling & Sales Lead        GRAD    CERTG     COB
## 2689:    NDOUHP            Ohio Honors Program        UGRD NONDOTHR     HTC
## 2690:    CTCCOM           Crisis Communication        GRAD    CERTG     COM
## 2691:    BF5057       Studio Art - Art Therapy        UGRD      BFA     FAR
##       dept_code acad_plan_type eff_status
##    1:        36            MAJ          I
##    2:        21            CRT          A
##    3:        81            CRT          A
##    4:        32            CRT          A
##    5:        79            MAJ          A
##   ---                                    
## 2687:        25            CRT          A
## 2688:        25            CRT          A
## 2689:        89            HON          A
## 2690:        75            CRT          A
## 2691:        53            MAJ          A
```
