read_in_data <- function(stream) {
  data <- read.csv(paste0("results/", stream, "/output-wiki-pred-race.csv"))
  data$stream <- rep(stream, nrow(data))
  return(data)
}

streams <- c("stream_01", "stream_02", "stream_03", "stream_04", "stream_05")

all_data <- lapply(streams, read_in_data)
all_data <- do.call("rbind", all_data)
write.csv(all_data, "merged_age_gender_race.csv")


library(tidyverse)

calc_percentages <- function(input_stream) {
  subs <- all_data %>%
    dplyr::filter(stream == input_stream) %>%
    dplyr::group_by(race, pred_gender) %>%
    dplyr::summarise(n=n()) %>%
    filter(pred_gender != "") %>%
    ungroup() %>%
    dplyr::mutate(percentage = n/sum(n)) %>%
    dplyr::mutate(stream = input_stream)
  return(subs)
}

percs <- lapply(streams, calc_percentages)
percs <- do.call("rbind", percs)

ggplot(data=percs, aes(x=race, y=percentage))+
  geom_col(aes(group=pred_gender, fill=pred_gender))+
  facet_wrap(.~stream)+
  coord_flip()+
  theme_bw()

all_data$race[all_data$pred_gender == ""] <- NA
