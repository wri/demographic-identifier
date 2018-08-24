library(json)

files <- list.files("master-scripts/stream_01", pattern = "[.]gz")
files <- paste0("master-scripts/stream_01/", files)
read_in_file <- function(file) {
  z <- gzfile(file)
  l <- jsonlite::flatten(jsonlite::stream_in(z))
  return(l)
}

all_files <- lapply(files, read_in_file)
#all_files <- lapply(all_files, as.data.frame)
library(plyr)
all_files <- rbind.fill(all_files)

images <- all_files$user.profile_image_url_https
images <- gsub("_normal", "", images)
destfiles <- seq(1, length(images), 1)
destfiles <- paste0(destfiles, ".jpg")

download.file(images[2], method="curl", destfile = "image1.jpg")

for(i in c(1:length(images))) {
  Sys.sleep(0.1)
  download.file(images[i], method="curl", destfile = destfiles[i])
}
