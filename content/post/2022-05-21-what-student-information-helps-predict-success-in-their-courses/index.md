---
title: What student information helps predict success in their courses?
author: Kent Orr
date: '2022-05-21'
slug: what-student-information-helps-predict-success-in-their-courses
categories: []
tags: []
---

## Defining the Problem 

This research question builds on our prior understanding of the term **success** being a C or better grade. We want to seek out variables that can predict official grades of a C or above. We also know that we want to work within the confines of student information. Because we know we'll need the `course_enrollments` data, we can reference the data keys and columns to see what relational databases have student information which we can connect to successful outcomes. 

`course_enrollments` shares keys with `student_details` and `acad_plan`. There are of course other relations, but it seems safe to rule them out when considering the small scope of student information.



## Creating the Query

We want to merge student attributes with their course data using a left join. 


```r
cs <- course_enrollments[,merge(.SD, student_details)]
```

### Cleaning the query

The resulting data set gives the first obstacle, handling `NA` values for numeric variables. On the one hand a scalar response lends itself to an elegant set of predictive methods, but at the same time not having a high school GPA entry is likely a significant indicator of academic success. The same goes for whether a student took the ACT or not. Even worse, the percentage of respondents missing one or the other are close to a quarter or a third. 


```r
lapply(cs[,.(act_score, hs_gpa_entry)], \(x) {length(x)/length(x[which(is.na(x))])})
```

```
## $act_score
## [1] 24.8786
## 
## $hs_gpa_entry
## [1] 32.27362
```

For each variable we will answer two questions that help us decide what to do next.

1. Is non-response predictive of course success?  
2. Is there a linear relationship between selected variables and successful outcomes?  

#### act_score


```r
copy(cs)[,.N, .(act_na = is.na(act_score), success)][,percent := N/sum(N), act_na] |>
  ggplot(aes(x = act_na, y = success, fill = percent, 
             label = scales::percent(percent, accuracy = 1))) + 
  geom_tile() + geom_label(color = "white") + 
  theme_classic() + theme(legend.position = "none") + 
  labs(title = "Distribution of ACT Resp vs. Non-Resp",
       x = "ACT Score Reported", y = "C or Above")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-3-1.png" width="672" />

```r
copy(cs)[,.(act_na = is.na(act_score), success)] |> 
  table() |> 
  chisq.test()  
```

```
## 
## 	Pearson's Chi-squared test with Yates' continuity correction
## 
## data:  table(copy(cs)[, .(act_na = is.na(act_score), success)])
## X-squared = 25.256, df = 1, p-value = 5.021e-07
```

While a quick visual inspection shows the potential of a linear relationship in grades earned in class, such as D- to A, the same does not hold true for the various other grades which do not qualify as `success`. When simply comparing all successful respondents with an ACT score with those who did not succeed, there is no immediately distinguishable hierarchy. 


```r
copy(cs) |>
  ggplot(aes(x = act_score, y = official_grade)) + 
  ggridges::geom_density_ridges()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-1.png" width="672" />

```r
copy(cs) |>
  ggplot(aes(x = act_score, y = success)) + 
  ggridges::geom_density_ridges()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-2.png" width="672" />

To capture the scalar effect on D grades and above, and to capture the categorical effect for WF, DROP, and others, I will create and ordered factor of the `act_score` variable using `No Score` and quartiles. 


```r
cs$act_score |> quantile(seq(0, 1, .25), na.rm = T) -> x
cs$act_score <- cs$act_score |> cut(x) |> as.character()
cs$act_score[which(is.na(cs$act_score))] <- "No Score"
cs$act_score <- cs$act_score |> factor(levels = c("No Score", "(13,21]",  "(21,23]",  "(23,26]",  "(26,35]"))
```

