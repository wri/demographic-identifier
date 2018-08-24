library(gender)
results <- read.csv("results/results_full.csv")
results$name <- as.numeric(gsub("[.]jpg", "", results$name))
all_files$sample <- seq(1, nrow(all_files), 1)

user_name <- all_files[,colnames(all_files) %in% c("sample", "user.name", "user.screen_name")]
colnames(user_name) <- c("screen.name", "user.name", "name")
results <- left_join(results, user_name)

first.name <- gsub("([A-Za-z]+).*", "\\1", results$user.name)
results$first.name <- first.name
gend <- gender(first.name)[,c(1:4)]
colnames(gend) <- c("first.name", "name_male", "name_female", "name_gender")
results <- left_join(results, gend)
results <- results[!duplicated(results),]
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

output <- results_unique[,c(2,5,6,7,13)]
