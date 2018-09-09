#! /usr/bin/Rscript

library(tidyverse)
names <- read.csv("../results/names.csv", header = F)
colnames(names) <- c("name")
results <- read.csv("../results/results.csv", header=F)
colnames(results) <- c("age", "gender")
results$age <- gsub("\\[|\\]", "", results$age)
results$gender <- gsub("\\[|\\]", "", results$gender)
results$n <- str_count(results$age, "\\s+") + 1 
results$n[is.na(results$n)] <- 1
#results <- cbind(results, names)
df.expanded <- results[rep(row.names(results), results$n),]
df.expanded$n <- 1

df.expanded$duplicated <- F
for(i in c(2:nrow(df.expanded))) {
  df.expanded$duplicated[i] <- (df.expanded$age[i] == df.expanded$age[i-1])
  if(!is.na(df.expanded$duplicated[i])) {
    if(df.expanded$duplicated[i] == T) {
      df.expanded$n[i] <- df.expanded$n[i] + 1
    }
  }
}

df.expanded$age <- unlist(df.expanded$age)
for(i in c(1:nrow(df.expanded))) {
  if(!is.na(df.expanded$n[i])) {
    df.expanded$age[i] <- unlist(strsplit(df.expanded$age[i], "\\s+"))[df.expanded$n[i]]
    df.expanded$gender[i] <- unlist(strsplit(df.expanded$gender[i], "\n"))[df.expanded$n[i]]
  }
}

df.expanded <- df.expanded[,-c(4,5)]
colnames(df.expanded) <- c("age", "gender", "name")
df.expanded$gender <- gsub("\\s+", " ", df.expanded$gender)
df.expanded$gender <- gsub("^ | $", "", df.expanded$gender)
df.expanded <- df.expanded %>% separate(gender, c("female", "male"), sep = " ")
df.expanded[,c(1:3)] <- lapply(df.expanded[,c(1:3)], as.numeric)
df.expanded[,c(1:3)] <- lapply(df.expanded[,c(1:3)], function(x) round(x, 2))
df.expanded$age <- round(df.expanded$age, 0)

write.csv(df.expanded, "../results/results_full.csv")
