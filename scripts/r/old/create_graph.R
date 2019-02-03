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
topic <- topic %>% arrange(desc(Percent.female))
topic$Topic <- as.character(topic$Topic)
topic[,2:6] <- lapply(topic[,2:6], function(x) as.numeric(x))
topic[23,] <- c("Sustainable farming", NA, sum(topic[1:2,3]), sum(topic[1:2,4]), NA, sum(topic[1:2,6]))
topic[24,] <- c("Innovation & climate change", NA, sum(topic[c(3,8),3]), sum(topic[c(3,8),4]), NA, sum(topic[c(3,8),6]))
topic[25,] <- c("High-level panels", NA, sum(topic[c(16,17),3]), sum(topic[c(16,17),4]), NA, sum(topic[c(16,17),6]))
topic <- topic[-c(1,2,3,8,16,17, 9,10,11,12,14,15),]
topic[,2:6] <- lapply(topic[,2:6], function(x) as.numeric(x))
topic$Percent.female <- topic$Female / (topic$Male + topic$Female)

#bolded <- rep("plain", 22)
#bolded[10] <- "bold"

ggplot(data=topic, aes(x=reorder(Topic, Percent.female), y=Percent.female*100))+
  geom_col(aes(alpha = Percent.female))+
  coord_flip()+
  geom_hline(yintercept=43.4, linetype = "dashed")+
  ggridges::theme_ridges(center_axis_labels = TRUE)+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
       #axis.text.y=element_text(face = bolded),
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

demographic_clust %>% filter(grepl("Caucasian", race)) %>% arrange(desc(diff)) %>% View()

most_white <- c(85, 68, 72, 88, 161, 117, 142, 191, 18, 12)
least_white <- c(82, 108, 14, 150, 50, 107, 152, 99, 42, 16)

w_percent <- demographic_clust %>%
  filter(race == "Caucasian") %>%
  filter(clust %in% c(most_white, least_white))

white_df <- data.frame(Cluster = c(most_white, least_white))
white_df <- left_join(white_df, all_topics, by = c("Cluster" = "Clust"))
white_df <- dplyr::inner_join(white_df, w_percent, by = c("Cluster" = "clust"))

ggplot(data=white_df, aes(x=reorder(Topic, n), y=n*100))+
  geom_col(aes(alpha = n))+
  coord_flip()+
  ggridges::theme_ridges(center_axis_labels = TRUE)+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        #axis.text.y=element_text(face = bolded),
        legend.position = "none")+
  xlab("")+
  ylab("Percent white")

#asian
most_asian <- demographic_clust %>% filter(grepl("Asian", race)) %>% group_by(clust) %>% summarise(n = sum(n), diff = sum(n) - sum(avg)) %>% ungroup() %>% arrange(desc(diff)) %>% top_n(10)
least_asian <- demographic_clust %>% filter(grepl("Asian", race)) %>% group_by(clust) %>% summarise(n = sum(n), diff = sum(n) - sum(avg)) %>% ungroup() %>% arrange(desc(diff)) %>% top_n(-10)
asian_df <- rbind(most_asian, least_asian)
asian_df <- left_join(asian_df, all_topics, by = c("clust" = "Clust"))

#latino
most_latino <- demographic_clust %>% filter(grepl("Latino", race)) %>% group_by(clust) %>% summarise(n = sum(n), diff = sum(n) - sum(avg)) %>% ungroup() %>% arrange(desc(diff)) %>% top_n(10)
least_latino <- demographic_clust %>% filter(grepl("Latino", race)) %>% group_by(clust) %>% summarise(n = sum(n), diff = sum(n) - sum(avg)) %>% ungroup() %>% arrange(desc(diff)) %>% top_n(-10)
latino <- rbind(most_latino, least_latino)
latino <- left_join(latino, all_topics, by = c("clust" = "Clust"))

#black
most_black <- demographic_clust %>% filter(grepl("African", race)) %>% group_by(clust) %>% summarise(n = sum(n), diff = sum(n) - sum(avg)) %>% ungroup() %>% arrange(desc(diff)) %>% top_n(10)
least_black <- demographic_clust %>% filter(grepl("African", race)) %>% group_by(clust) %>% summarise(n = sum(n), diff = sum(n) - sum(avg)) %>% ungroup() %>% arrange(desc(diff)) %>% top_n(-10)
black <- rbind(most_black, least_black)
black <- left_join(black, all_topics, by = c("clust" = "Clust"))
