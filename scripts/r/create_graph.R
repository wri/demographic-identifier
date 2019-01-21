library(tidyverse)
library(ggridges)
figdata <- read.csv("master-scripts/output-wiki-pred-race.csv")
figdata$race <- as.character(figdata$race)
figdata$race[figdata$race == "GreaterEuropean,WestEuropean,Hispanic"] <- "Latino"
figdata$race[figdata$race %in% c("Asian,GreaterEastAsian,Japanese",
            "Asian,GreaterEastAsian,EastAsian")] <- "Asian"

figdata$race[figdata$race %in% c("GreaterEuropean,WestEuropean,Germanic",
                               "GreaterEuropean,WestEuropean,Italian",
                               "GreaterEuropean,WestEuropean,French",
                               "GreaterEuropean,British",
                               "GreaterEuropean,WestEuropean,Nordic",
                               "GreaterEuropean,Jewish",
                               "GreaterEuropean,EastEuropean"
                               )] <- "Caucasian"

figdata$race[figdata$X__name == "nan nan"] <- NA

means <- figdata %>%
  dplyr::group_by(race) %>%
  dplyr::summarise(age = mean(age, na.rm=T))

figdata <- all_data %>%
  dplyr::group_by(age, pred_gender, race) %>%
  dplyr::summarise(n=n())%>%
  as.data.frame()

figdata$n <- as.numeric(figdata$n)
figdata <- figdata[!is.na(figdata$race),]

p1 <- ggplot(data=figdata, aes(x=age, y=n, fill=pred_gender))+
  geom_col(stat="identity", data=figdata[figdata$pred_gender=="female",], width=1)+
  geom_col(stat="identity", data=figdata[figdata$pred_gender=="male",], aes(y=n*-1), width=1)+
  coord_flip()+
  theme_minimal()+
  scale_x_continuous(breaks=seq(10,70,10))+
  theme(panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank())+
  facet_wrap(.~race)

##### GENDER BY TOPIC #######
topic <- read.csv("data/processed/topic_gender.csv")
bolded <- rep("plain", 22)
bolded[10] <- "bold"

ggplot(data=topic, aes(x=reorder(Topic, Percent.female), y=Percent.female*100))+
  geom_col(aes(alpha = Percent.female))+
  coord_flip()+
  geom_hline(yintercept=43.4, linetype = "dashed")+
  theme_ridges(center_axis_labels = TRUE)+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.y=element_text(face = bolded),
        legend.position = "none")+
  xlab("")+
  ylab("Percent female")

##### AGE BY TOPIC ######
age <- read.csv("data/processed/age_data.csv")
age$over <- "No"
age$over[age$age > 37.14] <- "Yes"
age <- age %>%
  group_by(name) %>%
  mutate(age_mean = mean(age),
         quantile = quantile(age, 0.5))

bolded <- rep("plain", 19)
bolded[11] <- "bold"

t1 <- textGrob(expression("Average age of Twitter users by topic and " * phantom("overall")),
               x = 0.5, y = 1.1, gp = gpar(col = "black"))

t2 <- textGrob(expression("Average age of Twitter users by topic and " * phantom("overall")),
               x = 0.5, y = 1.1, gp = gpar(col = "red"))

ggplot(data = age, aes(x=age, y = reorder(name, quantile)))+
  stat_density_ridges(calc_ecdf = TRUE, quantile_lines = TRUE, quantiles = 2, linetype = "dashed", fill = "grey80")+
  geom_density_ridges(alpha=0)+
  geom_vline(xintercept=36, alpha = 0.7, color = "red", linetype = "dashed")+
  theme_ridges(center_axis_labels = TRUE)+
  theme(axis.text.y=element_text(face = bolded))+
  xlab("Age")+
  ylab("")+
  ggtitle("Average age of Twitter users by topic and overall")

#### RACE DATA #####


dem <- readRDS("data/processed/ethn_topic_embeddings.rds")
dem_topics <- dem[,]
ethn <- read.csv("data/processed/merged_age_gender_race.csv")
ethn <- ethn[!is.na(ethn$race) & !is.na(ethn$pred_gender),]
ethn <- ethn[,c(5,10)]
dem$clust <- dem$clust$V1
### DEM: user.name, ETHN: user.name
dem <- left_join(dem, ethn)
saveRDS(dem, "data/processed/ethn_topic_embeddings.rds")

dem$race <- as.character(dem$race)
dem$race[dem$race == "GreaterEuropean,WestEuropean,Hispanic"] <- "Latino"
dem$race[dem$race %in% c("Asian,GreaterEastAsian,Japanese",
                                 "Asian,GreaterEastAsian,EastAsian")] <- "Asian"

dem$race[dem$race %in% c("GreaterEuropean,WestEuropean,Germanic",
                                 "GreaterEuropean,WestEuropean,Italian",
                                 "GreaterEuropean,WestEuropean,French",
                                 "GreaterEuropean,British",
                                 "GreaterEuropean,WestEuropean,Nordic",
                                 "GreaterEuropean,Jewish",
                                 "GreaterEuropean,EastEuropean"
)] <- "Caucasian"

dem$race[dem$X__name == "nan nan"] <- NA
dem <- dem[!is.na(dem$race),]

demographic_clust <- dem %>%
  group_by(race, clust) %>%
  summarise(n = n()) %>%
  na.omit() %>%
  ungroup() %>%
  group_by(clust) %>%
  mutate(n = n/sum(n))

demographic_clust <- demographic_clust %>%
  group_by(race) %>%
  mutate(avg = mean(n))%>%
  ungroup() %>%
  mutate(diff = n-avg)

# make a topic - cluster dataframe of this shiiiiit
most_white <- c(142, 85, 72, 88, 191, 117, 68, 46, 199, 161)
least_white <- c(167, 108, 99, 82, 107, 14, 113, 197, 150, 47)
topics_most_w <- c("Forecasting and statistics", "Forestry reports", "Co-benefits of restoration", "Bankgkok UNFCCC", "Water stress",
                  "Trump & natural disasters - negative", "Dan Rather coverage of climate change", "Forest biogeochemistry", "Water pollution", "Climate commitments")
topics_least_w <- c("Women's health & SDGs", "African youth innovation - Nigeria", "Water intensive supply chains", "Olumide Idowu birthday wishes",
                    "Women's rights - African rural villages", "Youth initiatives", "Youth movement building", "African politics",  "Personal responsibility", "African political cooperation")

w_percent <- demographic_clust %>%
  filter(race == "GreaterEuropean,British") %>%
  filter(clust %in% c(most_white, least_white))

white_df <- data.frame(Cluster = c(most_white, least_white), Topic = c(topics_most_w, topics_least_w))
white_df <- dplyr::inner_join(white_df, w_percent, by = c("Cluster" = "clust"))

ggplot(data=white_df, aes(x=reorder(Topic, n), y=n*100))+
  geom_col(aes(alpha = n))+
  coord_flip()+
  theme_ridges(center_axis_labels = TRUE)+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        #axis.text.y=element_text(face = bolded),
        legend.position = "none")+
  xlab("")+
  ylab("Percent white")

all_topics <- topic[c(1,2)]
all_topics <- rbind(all_topics, data.frame(Topic = white_df$Topic, Clust = white_df$Cluster))

#asian
most_asian <- c(178, 53, 107, 174, 149, 118, 187, 43, 168, 175)

#latino
demographic_clust %>% filter(grepl("Hispanic", race)) %>% arrange(desc(diff)) %>% View()

#black
demographic_clust %>% filter(grepl("African", race)) %>% arrange(desc(diff)) %>% View()
most_black <- c(150, 82, 15, 50, 36, 197, 41, 14, 158, 178)
least_black <- c(115, 117, 168, 68, 88, 96, 191, 65, 100, 174, 104, 57, 53)