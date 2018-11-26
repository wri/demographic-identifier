stream_number <- 3
stream = paste0("../../glf-data/stream_0", stream_number)
cat("The stream number is", stream_number, "\n")

files <- list.files(stream, pattern = "[.]gz")
files <- paste0(stream, "/", files)


read_in_file <- function(file) {
  z <- gzfile(file)
  l <- jsonlite::flatten(jsonlite::stream_in(z))
  Sys.sleep(1)
  return(l)
}

all_files <- lapply(files, read_in_file)
all_files <- plyr::rbind.fill(all_files)

all.subs <- all_files[,colnames(all_files) %in% c("created_at", "retweet_count", "favorite_count", "user.friends_count", "text", "place", 
                                                  "reply_count", "user.screen_name", "user.name", "user.location",
                                                  "place.country", "place.name", "extended_tweet.full_text")]

saveRDS(all.subs, paste0("stream_0", stream_number, "_filtered.rds"))

#gsub("\\s+#[A-z]{1,}|\\s+@[A-z]{1,}|?(f|ht)(tp)(s?)(://)(.*)[.|/](.*)|^RT|\n|:|amp;|\\n", "", all.subs$text)

############

read_in_file <- function(file) {
  z <- gzfile(file)
  l <- jsonlite::flatten(jsonlite::stream_in(z))
  Sys.sleep(1)
  return(l)
}

all_data_filtered <- read_in_file("2018_community_filtered.json.gz")

all_files <- lapply(files, read_in_file)
all_files <- plyr::rbind.fill(all_files)

all.subs <- all_data_filtered[,colnames(all_data_filtered) %in% c("created_at", "retweet_count", "favorite_count", "user.friends_count", "text", "place", 
                                                  "reply_count", "user.screen_name", "user.name", "user.location",
                                                  "place.country", "place.name", "extended_tweet.full_text")]

saveRDS(all.subs, "2018_filtered.rds")
