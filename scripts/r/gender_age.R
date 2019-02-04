#! /usr/bin/Rscript

suppressMessages(library(tidyverse))
stream = "stream_05/"

cat("Reading in data \n")
results <- read.csv(paste0("../results/", stream, "results.csv"), header=F)
colnames(results) <- c("age", "gender")
results$age <- gsub("\\[|\\]", "", results$age)
results$gender <- gsub("\\[|\\]", "", results$gender)
results$n <- str_count(results$age, "\\s+") + 1 
results$n[is.na(results$n)] <- 1



cat("Separating individuals in images \n")
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

cat("Separating age and gender of duplicates \n")
df.expanded$age <- unlist(df.expanded$age)
for(i in c(1:nrow(df.expanded))) {
  if(!is.na(df.expanded$n[i])) {
    df.expanded$age[i] <- unlist(strsplit(df.expanded$age[i], "\\s+"))[df.expanded$n[i]]
    df.expanded$gender[i] <- unlist(strsplit(df.expanded$gender[i], "\n"))[df.expanded$n[i]]
  }
}

cat("Formatting results \n")
df.expanded <- df.expanded[,-c(4,5)]
colnames(df.expanded) <- c("age", "gender", "name")
df.expanded$gender <- gsub("\\s+", " ", df.expanded$gender)
df.expanded$gender <- gsub("^ | $", "", df.expanded$gender)
df.expanded <- df.expanded %>% separate(gender, c("female", "male"), sep = " ")
df.expanded[,c(1:3)] <- lapply(df.expanded[,c(1:3)], as.numeric)
df.expanded[,c(1:3)] <- lapply(df.expanded[,c(1:3)], function(x) round(x, 2))
df.expanded$age <- round(df.expanded$age, 0)

cat("Reading in zipped JSONs \n")
results <- df.expanded
results$name <- gsub("[.]{1,}/img_[0-9]{1,}/", "", results$name)
results$name <- as.numeric(gsub("[.]jpg", "", results$name))
files <- list.files(stream, pattern = "[.]gz")
files <- paste0(stream, "/", files)
read_in_file <- function(file) {
  z <- gzfile(file)
  l <- jsonlite::flatten(jsonlite::stream_in(z))
  return(l)
}

#finished_files <- read.table("finished_files.txt", col.names = F, as.is=T)
#colnames(finished_files) <- c("file")
#files <- files[!files %in%  finished_files$file]
if(length(files) > 0) {
  all_files <- lapply(files, read_in_file)
  all_files <- plyr::rbind.fill(all_files)
}

#cat("Reading in data \n")
#prior <- readRDS("all_files.RDS")
if(length(files) > 0) {
  original_cols <- colnames(all_files)
  #to_keep <- which(colnames(prior) %in% original_cols)
  #print(to_keep)
  #prior <- prior[,to_keep]
  #all_files <- rbind(prior, all_files)
  saveRDS(all_files, paste0("../results/", stream, "/all_files.RDS"))
  
  files <- list.files(stream, pattern = "[.]gz")
  files <- paste0(stream, "/", files)
  write.table(files, paste0("../results/", stream, "/finished_files.txt", row.names = F, col.names = F, quote = F))
} else {
  all_files <- prior
  rm(prior)
}
all_files$sample <- seq(1, nrow(all_files), 1)
user_name <- all_files[,colnames(all_files) %in% c("sample", "user.name", "user.screen_name")]
colnames(user_name) <- c("screen.name", "user.name", "name")

cat("Cleaning up user name encoding and spelling\n")
user_name$user.name <- gsub("^The\\s+|^El\\s+|^Sir\\s+|^Le\\s+|^el\\s+|^EL\\s+|^Dr\\s+|^Dr[.]\\s+|^Mr\\s+|^Mr[.]\\s+|^Ms\\s+|^Ms[.]\\s+|^Mrs\\s+|^Mrs[.]\\s+", "", user_name$user.name)
user_name$user.name <- gsub("_", " ", user_name$user.name)
user_name$user.name[grepl("[0-9]", user_name$user.name)] <- NA
user_name$user.name <- gsub("[[:punct:]]", " ", user_name$user.name)
user_name$user.name <- stringi::stri_trans_general(user_name$user.name, "latin-ascii")
user_name$user.name<- iconv(user_name$user.name, "UTF-8", "ASCII", sub = "")
user_name$user.name <- gsub("[0-9]{1,}", "", user_name$user.name)
user_name$user.name <- iconv(user_name$user.name, to='ASCII//TRANSLIT')
results <- dplyr::left_join(results, user_name)

cat("Cleaning up first and last name encoding and spelling\n")
first.name <- gsub("([A-Za-z]+).*", "\\1", results$user.name)
results$last.name <- gsub('^.* ([[:alnum:]]+)$', '\\1', results$user.name)
results$first.name <- first.name

cat("Calculating gender with U.S. Census data\n")
gend <- gender(first.name)[,c(1:4)]
colnames(gend) <- c("first.name", "name_male", "name_female", "name_gender")
results <- left_join(results, gend)
results <- results[!duplicated(results),]

cat("Calculating mismatch between photo and name-based gender\n")
results$photo_gender <- NA
results$photo_gender[results$male > 0.5] <- "male"
results$photo_gender[results$female > 0.5] <- "female"
results_unique <- results[!duplicated(results$screen.name),]
results_unique$pred_gender <- NA
match <- results_unique$photo_gender == results_unique$name_gender
match[is.na(match)] <- F
results_unique$pred_gender[match == T] <- results_unique$name_gender[match == T]
results_unique$pred_gender[is.na(results_unique$name_gender) & !is.na(results_unique$photo_gender)] <- results_unique$photo_gender[is.na(results_unique$name_gender) & !is.na(results_unique$photo_gender)]
results_unique$pred_gender[is.na(results_unique$photo_gender) & !is.na(results_unique$name_gender)] <- results_unique$name_gender[is.na(results_unique$photo_gender) & !is.na(results_unique$name_gender)]
mismatch <- results_unique[which(is.na(results_unique$pred_gender) & results_unique$photo_gender != results_unique$name_gender),]
mismatch$pred_gender[mismatch$photo_gender == "male" & mismatch$name_female > mismatch$name_male] <- "female"
mismatch$pred_gender[mismatch$photo_gender == "female" & mismatch$name_male > mismatch$name_female] <- "male"
results_unique$pred_gender[which(results_unique$screen.name %in% mismatch$screen.name)] <- mismatch$pred_gender

cat("Fixing more spelling errors\n")

'''
The below section of code corrects common spelling, encoding, and white space errors
that were common issues with first and last names on Twitter
'''
output <- results_unique[,c(2,5,6,7,8,9,14)]
output$last.name[grepl("[0-9]", output$last.name)] <- NA
output$last.name <- trimws(gsub("\\S+\\s+|-", " ", output$last.name))
output$last.name <- gsub('\\p{So}|\\p{Cn}', '', output$last.name, perl = TRUE)
output$last.name <- gsub("[[:punct:]]", " ", output$last.name)
output$last.name <- stringi::stri_trans_general(output$last.name, "latin-ascii")
output$last.name <- iconv(output$last.name, "UTF-8", "ASCII", sub = "")
output$last.name <- gsub("[0-9]{1,}", "", output$last.name)
output$last.name <- iconv(output$last.name, to='ASCII//TRANSLIT')

output$last.name <- enc2utf8(output$last.name)
output$last.name <- as.character(output$last.name)
output$last.name <- as.character(output$last.name)
output$last.name[output$last.name == ""] <- NA


output$first.name[grepl("[0-9]", output$first.name)] <- NA
output$first.name <- trimws(gsub("\\S+\\s+|-", " ", output$first.name))
output$first.name <- gsub('\\p{So}|\\p{Cn}', '', output$first.name, perl = TRUE)
output$first.name[grepl("\\@", output$first.name)] <- NA
output$first.name <- enc2utf8(output$first.name)
output$first.name <- gsub("[[:punct:]]", " ", output$first.name)
output$first.name <- gsub("[0-9]{1,}", "", output$first.name)
output$first.name <- stringi::stri_trans_general(output$first.name, "latin-ascii")
output$first.name <- iconv(output$first.name, "UTF-8", "ASCII", sub = "")
output$first.name <- iconv(output$first.name, to='ASCII//TRANSLIT')
output$first.name <- as.character(output$first.name)
output$first.name[output$first.name == ""] <- NA

cat("Saving output for Twitter handles with at least one of valid name or photo\n")
valid_names <- gender(output$first.name)[,1]
write.csv(output, paste0("../results/", stream, "/results_gender_age.csv"),row.names = F)