## Gender chi-square
library(tidyverse)

gender <- data.frame(gender = dem_all$pred_gender, user.name = dem_all$user.name)
gender <- left_join(gender, english)

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
gender_dist$Topic[gender_dist$clust %in% c(60,68, 96, 104)] <- c("Animal Rights", "Natural Disasters", "Endangered Species", "Forest Species")
gender_dist$Topic[gender_dist$clust %in% c(43, 72, 85, 126, 142, 164)] <- c("Proverbs", "Restoration data", "Illegal logging",
                                                                            "Political unrest", "Early warning systems", "Corruption")
gender_dist$Color <- "Other topics"
gender_dist$Color[!is.na(gender_dist$Topic)] <- "Extreme gender disproportion"
gender_dist <- gender_dist[gender_dist$percent_f > 0.12 & gender_dist$percent_f < 0.7,]

ggplot(data = gender_dist, aes(y = percent_f*100, x = grouping))+
  ggbeeswarm::geom_quasirandom(aes(color = Color))+
  ggrepel::geom_label_repel(label = gender_dist$Topic, box.padding = 0.6)+
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



## Ethn chi-square
dem_stats <- dem %>%
  group_by(clust, race) %>%
  summarise(n = n())
dem_stats <- spread(dem_stats, race, n, -dem_stats$clust)
dem_stats <- as.data.frame(t(dem_stats[-201,-1]))
chisq.test(dem_stats)


dem_stats <- as.data.frame(t(dem_stats))
dem_stats$percent_w <- dem_stats$Caucasian/ rowSums(dem_stats)
dem_stats$clust <- seq(0, 199)
dem_stats$grouping <- rep("Ethn", 200)
dem_stats$Topic <- NA
dem_stats$Topic[dem_stats$clust %in% c(68, 72, 85, 88, 161, 117, 142)] <- c("Climate change and U.S. politics", "Co-benefits of restoration", "Policy reports", "UNFCCC Bangkok", "City initiatives", "US politics", "Statistics & Data")
dem_stats$Topic[dem_stats$clust %in% c(14, 50, 82, 108, 150)] <- c("Youth initiatives", "Female education", "Idowu birthday wishes", "Youth innovation", "Personal responsibility")
dem_stats <- dem_stats[dem_stats$percent_w < 0.8,]
dem_stats$Color <- "Other topics"
dem_stats$Color[!is.na(dem_stats$Topic)] <- "Extreme race disproportion"

ggplot(data = dem_stats, aes(y = percent_w*100, x = grouping))+
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
  ylab("Percent white")+
  xlab("")+
  ggtitle("Percent caucasian of 200 identified Twitter topics")

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

youth_stats <- youth_stats %>%
  group_by(clust) %>%
  mutate(perc = n[youth == "Yes"] / sum(n))

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
