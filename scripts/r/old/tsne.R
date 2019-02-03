### TSNE

filtered <- readRDS("data/processed/2018_filtered.rds")

detect_language <- function(n) {
  lang <- cld2::detect_language(as.character(n))
  return(lang)
}

langs <- lapply(filtered$text, detect_language)
english <- filtered[langs == "en",]
english <- english[nchar(english$text) > 50,]
english$text <- gsub("[\r\n]", " ", english$text)
english <- english[!is.na(english$text),]
write.csv(english, "data/processed/english.csv", row.names = F, quote = F)
write.table(english$text, "data/processed/english_text.txt", row.names = F, quote = F, col.names = F)


embeddings <- read.table("data/processed/embeddings.txt")
library(Rtsne)
tsne <- Rtsne(embeddings, check_duplicates = F, verbose = T)
tsne_best <- as.data.frame(tsne$Y)
kmns <- kmeans(as.matrix(embeddings), centers = 250, trace = F, iter.max = 100)

dem_1 <- read.csv("data/raw/results/stream_01/output-wiki-pred-race.csv")
dem_2 <- read.csv("data/raw/results/stream_02/output-wiki-pred-race.csv")
dem_3 <- read.csv("data/raw/results/stream_03/output-wiki-pred-race.csv")
dem_4 <- read.csv("data/raw/results/stream_04/output-wiki-pred-race.csv")
dem_5 <- read.csv("data/raw/results/stream_05/output-wiki-pred-race.csv")
dem_all <- do.call("rbind", list(dem_1, dem_2, dem_3, dem_4, dem_5))
saveRDS(dem_all, "data/processed/demographics.rds")

joined <- dplyr::left_join(filtered, dem, by.x="user.screen_name", by.y="screen.name")
joined <- joined[langs == "en",]
joined <- joined[nchar(joined$text) > 50,]
joined$text <- gsub("[\r\n]", " ", joined$text)
joined <- joined[!is.na(joined$text),]
write.table(joined$pred_gender, "data/processed/gender.txt", col.names = F, row.names = F, quote = F)



