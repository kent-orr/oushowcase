---
title: What is the Overall Success Rate?
author: Kent Orr
date: '2022-05-21'
slug: what-is-the-overall-success-rate
categories: []
tags: []
---
<script src="{{< blogdown/postref >}}index_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index_files/lightable/lightable.css" rel="stylesheet" />

What are our overall success rates? (C or better). To determine this simple ratio, we first need to factor success in accordance with the `course_enrollments` data set which includes official grades. 


```r
source("~/Documents/oushowcase/content/scripts/clean.R")

copy(raw_data$course_enrollments)[ 
  # spare the typing and use regex to find successful scores
  ,success := grepl("A|B|C(?!\\-)", official_grade, perl = T) & 
    completed_flag == 1 & official_grade != "NC" # the one that got away
  ][,.N, success
    ][,percent := N/sum(N)
      ][] |>
  {\(x) {
    assign("success_rate", x[(success)]$percent,
           envir = .GlobalEnv)
    return(x)
  }}() |>
  kableExtra::kable(format.args = list(big.mark = ",", digits = 2)) |>
  kableExtra::kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> success </th>
   <th style="text-align:right;"> N </th>
   <th style="text-align:right;"> percent </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:right;"> 10,573 </td>
   <td style="text-align:right;"> 0.64 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 5,822 </td>
   <td style="text-align:right;"> 0.36 </td>
  </tr>
</tbody>
</table>

# There is a **64%** overall student success rate.
