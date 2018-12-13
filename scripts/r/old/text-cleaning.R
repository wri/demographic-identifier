filtered <- readRDS("2018_filtered.rds")

detect_language <- function(n) {
  lang <- cld2::detect_language(as.character(n))
  return(lang)
}

langs <- lapply(filtered$text, detect_language)