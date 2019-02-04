'''
This R script identifies links to images in a compressed JSON result from the Twitter API
Images are downloaded and placed into a predetermined file with a unique identifier that is logged to a separate file
The finished_files.txt and all_files.RDS allow the user to start and stop downloading, as rate limiting 
can force this process to take many hours
'''

folder_name <- "stream_01"
json_path <- "data/raw/2018_community_filtered.json.gz"
finished_path <- "data/raw/finished_files.txt"
finished_data <- "data/raw/all_files.RDS"

files <- list.files(folder_name, pattern = "[.]gz")
files <- paste0(folder_name, "/", files)

read_in_file <- function(file) {
  z <- gzfile(file)
  l <- jsonlite::flatten(jsonlite::stream_in(z))
  Sys.sleep(1)
  return(l)
}

file <- read_in_file(json_path)

if(file.exists(finished_path)) {
  finished_files <- read.table(finished_path, col.names = F, as.is=T)
  colnames(finished_files) <- c("file")
  files <- files[!files %in%  finished_files$file]
} else {
  temp <- NA
  write.table(temp, finished_path, col.names=F)
}



if(length(files) > 0) {
  all_files <- lapply(files, read_in_file)
  all_files <- plyr::rbind.fill(all_files)
}

cat("Reading in data \n")
if(file.exists(finished_data)) {
  prior <- readRDS(finished_data)
}
if(length(files) > 0) {
  original_cols <- colnames(all_files)
  if(exists("prior")) {
    to_keep <- which(colnames(prior) %in% original_cols)
    prior <- prior[,to_keep]
    all_files <- rbind(prior, all_files)
  }
  saveRDS(all_files, finished_data)
  
  files <- list.files(stream, pattern = "[.]gz")
  files <- paste0(stream, "/", files)
  write.table(files, finished_path, row.names = F, col.names = F, quote = F)
} else {
  all_files <- prior
  rm(prior)
}

cat("Calculating image names \n")
images <- file$user.profile_image_url_https
names <- file$user.screen_name
image_names <- data.frame(images = images, names = names)
image_names$images <- gsub("_normal", "", image_names$images)
image_names$destfiles <- seq(1, length(images), 1)
image_names$type <- gsub(".*\\.", "", image_names$images)
image_names$destfiles <- paste0(image_names$destfiles, ".", tolower(image_names$type))
image_names <- image_names[!duplicated(image_names$images),]
image_names <- image_names[image_names$type %in% c("jpg", "jpeg", "png", "bmp"),]
write.csv(image_names, "data/raw/image_names.csv")
#image_names <- read.csv("image_names.csv")
download_files <- function(ids) {
  #pb <- txtProgressBar(min = 0, max = end, initial = start, style = 3)
  for(i in ids) {
    print(i)
    print(image_names$images[i])
    #setTxtProgressBar(pb, i)
    Sys.sleep(sample(seq(0.1,0.50,0.01), 1))
    download.file(image_names$images[i], method="curl", destfile = paste0("data/img/", image_names$destfiles[i]), quiet = T)
  }
}

cat("Calculating where to start downloading \n")
downloaded <- list.files("../img/")
downloaded_number <- as.numeric(gsub("[.][A-z]{1,}", "", downloaded))

to_download <- which(!image_names$destfiles %in% downloaded)
length_to_download <- length(to_download)
#write.table(downloaded_urls, paste0("../results/", stream, "/downloaded_urls.txt", #row.names=F, col.names =F, quote = F))
#to_start <- which(image_names$destfiles == downloaded[which.max(downloaded_number)]) + 1


cat("Downloading", length_to_download, "images \n")
if(identical(to_download, numeric(0))) {
  #rm(to_start)
  to_download <- image_names$images
}
download_files(to_download)
