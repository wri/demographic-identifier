'''
This R script identifies and subsetts English tweets, as the specified language model 
(Universal sentence encoder) cannot process non-english tweets. I plan to conver this script to
be included in the python data cleaning script.
'''

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
#english$clust <- clusts
saveRDS(english, "data/processed/ethn_topic_embeddings.rds")
write.csv(english, "data/processed/english.csv", row.names = F, quote = F)
write.table(english$text, "data/processed/english_text.txt", row.names = F, quote = F, col.names = F)
