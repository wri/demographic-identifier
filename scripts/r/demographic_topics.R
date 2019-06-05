## Gender chi-square
library(tidyverse)

dem_all <- readRDS("data/processed/demographics.rds")

gender <- data.frame(gender = dem_all$pred_gender, user.name = dem_all$user.name)
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
clusts <- read.csv("data/processed/3-embeddings/cluster_ids.txt", col.names = "clust", header = F)
english$clust <- clusts$clust
gender <- dplyr::inner_join(gender, english)

gender_stats <- gender[gender$gender != "",] %>%
  group_by(clust, gender) %>%
  summarise(n = n())

gender_stats <- spread(gender_stats, gender, n, -gender_stats$clust)
gender_stats <- gender_stats[-201,]
gender_stats <- gender_stats[,-1]
gender_stats <- as.data.frame(t(gender_stats))
chisq.test(gender_stats)

gender_dist <- as.data.frame(t(gender_stats))
gender_dist$percent_f <- gender_dist$female / (gender_dist$male + gender_dist$female)
gender_dist$clust <- seq(0, 199)
gender_dist$grouping <- rep("Gender", 200)
gender_dist$Topic <- NA
# Remove 117, 119, 43, 88, 
gender_dist <- gender_dist[!gender_dist$Topic %in% c(117, 119, 43, 88),]
gender_dist$Topic[gender_dist$clust %in% c(60,68, 96, 104, 144, 198)] <- c("Animal rights", "Natural disasters", "Endangered species", "Forest species", "Food security", "Success stories")
gender_dist$Topic[gender_dist$clust %in% c(72, 85, 126, 142, 164, 108)] <- c("Restoration data", "Illegal logging",
                                                                            "Political unrest", "Early warning systems", "Corruption",
                                                                            "Supply chains")
gender_dist$Color <- "Other topics"
gender_dist$Color[!is.na(gender_dist$Topic)] <- "Extreme gender disproportion"
gender_dist <- gender_dist[gender_dist$percent_f > 0.12 & gender_dist$percent_f < 0.7,]

genplot <- ggplot(data = gender_dist, aes(y = percent_f*100, x = grouping))+
  ggbeeswarm::geom_quasirandom(aes(color = Color))+
  #ggrepel::geom_label_repel(label = gender_dist$Topic, box.padding = 0.6)+
  theme_minimal()+
  scale_color_manual(values = c("red", "grey"))+
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_blank(),
        legend.title = element_blank(),
        legend.position = "top",
        legend.justification = "left",
        plot.title = element_text(vjust = -2)
        )+
  ylab("Percent female")+
  xlab("")+
  labs(title = ("Percent female of 200 Twitter topics"))

genplotdata <- ggplot_build(genplot)$data[[1]]
gender_dist$percent_f <- gender_dist$percent_f*100
gender_2 <- left_join(gender_dist, genplotdata, by=c("percent_f" = "y"))

genplot2 <- ggplot(data = gender_2, aes(y = percent_f, x = x))+
  geom_point(aes(color = Color))+
  ggrepel::geom_label_repel(label = gender_2$Topic, box.padding = 0.6)+
  theme_minimal(base_size = 10)+
  scale_color_manual(values = c("red", "grey"))+
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_blank(),
        legend.title = element_blank(),
        legend.position = "top",
        legend.justification = "left",
        plot.title = element_text(vjust = -2)
  )+
  ylab("Percent female")+
  xlab("")+
  labs(title = ("Percent female of 200 Twitter topics"))


## Ethn chi-square
dem <- inner_join(dem_all, english)
dem_stats <- dem[dem$race != "",] %>%
  group_by(clust, race) %>%
  summarise(n = n())
dem_stats <- spread(dem_stats, race, n, -dem_stats$clust)
#dem_stats <- as.data.frame(t(dem_stats[-201,-1]))
chisq.test(dem_stats)


dem_stats <- as.data.frame(t(dem_stats))
dem_stats$percent_w <- dem_stats$Caucasian/ rowSums(dem_stats)
dem_stats$clust <- seq(0, 199)
dem_stats$grouping <- rep("Ethn", 200)
dem_stats$Topic <- NA


# Remove 68 (US Politics), 63, 180
# 4 <- carbon storage
# 18 <- Solheim / UN Environment
# 7 <- UNFCCC Tweets
# 94 <- Deforestation
# 167 <- UNDP Women's Rights


dem_stats <- dem_stats[!dem_stats$clust %in% c(68, 63, 180, 168, 107, 71, 187),]
dem_stats$Topic[dem_stats$clust %in% c(72, 85, 4, 18, 7, 94)] <- c("Co-benefits of restoration", "Policy reports", "Carbon storage", "Erik Solheim", "UNFCCC", "Deforestation statistics")
dem_stats$Topic[dem_stats$clust %in% c(108, 82, 167, 179, 99, 170)] <- c("Youth initiatives", "Idowu birthday wishes", "UNDP - Women's rights", "Technology and tree planting", "Unsustainable apparel", "Industrial pollution")
dem_stats <- dem_stats[dem_stats$percent_w < 0.8,]
dem_stats$Color <- "Other topics"
dem_stats$Color[!is.na(dem_stats$Topic)] <- "Extreme race disproportion"

demplot <- ggplot(data = dem_stats, aes(y = percent_w*100, x = grouping))+
  ggbeeswarm::geom_quasirandom(aes(color = Color))+
  theme_minimal()+
  ggrepel::geom_label_repel(label = dem_stats$Topic, box.padding = 0.6)+
  scale_color_brewer(palette = "Set1")+
  scale_color_manual(values = c("red", "grey"))+
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        legend.justification = "left",
        plot.title = element_text(vjust = -2)
  )+
  ylab("Percent caucasian")+
  xlab("")+
  ggtitle("Percent caucasian of 200 identified Twitter topics")

demplotdata <- ggplot_build(demplot)$data[[1]]
dem_stats$percent_w <- dem_stats$percent_w*100
dem2 <- left_join(dem_stats, demplotdata, by=c("percent_w" = "y"))

demplot2 <- ggplot(data = dem2, aes(y = percent_w, x = x))+
  geom_point(aes(color = Color))+
  theme_minimal(base_size = 10)+
  ggrepel::geom_label_repel(label = dem2$Topic, box.padding = 0.7)+
  scale_color_brewer(palette = "Set1")+
  scale_color_manual(values = c("red", "grey"))+
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        legend.justification = "left",
        plot.title = element_text(vjust = -2))+
  ylab("Percent caucasian")+
  xlab("")+
  ggtitle("Percent caucasian of 200 identified Twitter topics")

Rmisc::multiplot(genplot2, demplot2, cols = 2)

# remove 63, 129
### Youth and topics
youth <- data.frame(age = dem_all$age, user.name = dem_all$user.name)
youth <- inner_join(youth, english)
youth <- youth[!is.na(youth$age),]
youth$youth <- "No"
youth$youth[youth$age <= 24] <- "Yes"

youth_stats <- youth %>%
  group_by(clust, youth) %>%
  summarise(n = n())

youth_stats <- youth_stats[-259, ]

youth_stats <- youth_stats %>%
  dplyr::group_by(clust) %>%
  dplyr::mutate(perc = n[youth == "Yes"] / sum(n))

youth_stats$grouping <- "A"
youth_stats$Topic <- NA
youth_stats$Topic[youth_stats$clust %in% c(96, 191, 187, 60, 180, 73, 23, 108, 85, 161)] <- c("Whale shark day", "The long swim",
                                                                                     "Google maps and air polluttion", "Human-wildlife conflict",
                                                                                     "Plogging", "BBCAfrica - Youth artist", "Coastal conservation", "Youth innovation")

youth_stats$Topic[youth_stats$clust %in% c(147, 140, 56, 144, 2, 143)] <- c("Agriculture tech", "Liberia's president", "BBCAfrica - Rain control",
                                                                            "Youth employment in agriculture", "World Bank / UNEP - statistics",
                                                                            "Political unrest")

youth_stats$Color <- "Other topics"
youth_stats$Color[!is.na(youth_stats$Topic)] <- "Extreme youth disproportion"
youth_stats <- youth_stats[youth_stats$youth == "Yes",]

ggplot(data = youth_stats, aes(y = perc*100, x = grouping))+
  ggbeeswarm::geom_quasirandom(aes(color = Color))+
  theme_minimal()+
  ggrepel::geom_label_repel(label = youth_stats$Topic, box.padding = 0.6)+
  scale_color_manual(values = c("red", "grey"))+
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        legend.justification = "left",
        plot.title = element_text(vjust = -2)
  )+
  ylab("Percent youth (15-24)")+
  xlab("")+
ggtitle("Percent youth of 200 identified Twitter topics")
