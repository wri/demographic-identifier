filtered <- readRDS("data/processed/2018_filtered.rds")

detect_language <- function(n) {
  lang <- cld2::detect_language(as.character(n))
  return(lang)
}

langs <- lapply(filtered$text, detect_language)
english <- filtered[langs == "en",]
english <- english[nchar(english$text) > 50,]
write.csv(english, "data/processed/english.csv", row.names = F, quote = F)
