dem_before <- readRDS("data/processed/demographics.rds")
dem_all <- readRDS("data/processed/2018_filtered.rds")
dem_all <- dplyr::inner_join(dem_all, dem_before, by = c("user.screen_name" = "screen.name"))
dem_all <- dem_all[!is.na(dem_all),]


dem_all$race <- as.character(dem_all$race)
dem_all$race[dem_all$race == "GreaterEuropean,WestEuropean,Hispanic"] <- "Latino"
dem_all$race[dem_all$race %in% c("Asian,GreaterEastAsian,Japanese",
                         "Asian,GreaterEastAsian,EastAsian")] <- "Asian"

dem_all$race[dem_all$race %in% c("GreaterEuropean,WestEuropean,Germanic",
                         "GreaterEuropean,WestEuropean,Italian",
                         "GreaterEuropean,WestEuropean,French",
                         "GreaterEuropean,British",
                         "GreaterEuropean,WestEuropean,Nordic",
                         "GreaterEuropean,Jewish",
                         "GreaterEuropean,EastEuropean"
)] <- "Caucasian"

dem_all$race[grepl("Asian", dem_all$race)] <- "Asian"
dem_all$race[grepl("African", dem_all$race)] <- "African"

dem_all$race[dem_all$X__name == "nan nan"] <- NA

dem_all <- dem_all[rowSums(is.na(dem_all[,c(1,7,9)]))!=3,]


dem_all$age <- round(dem_all$age - 5, -1)



stats <- dem_all %>% group_by(pred_gender, race, age) %>%
  summarise(n = n())

ggplot(data=stats[!is.na(stats$race),], aes(x=age, y=n, fill=pred_gender))+
  geom_col(stat="identity", data=stats[stats$pred_gender=="female" & !is.na(stats$race),], width=10)+
  geom_col(stat="identity", data=stats[stats$pred_gender=="male" & !is.na(stats$race),], aes(y=n*-1), width=10)+
  coord_flip()+
  theme_minimal()+
  scale_x_continuous(breaks=seq(10,70,10))+
  theme(panel.grid.minor.x=element_blank(),
        panel.grid.major.y=element_blank(),
        panel.grid.minor.y = element_blank(),
        legend.title = element_blank(),
        legend.position = "bottom")+
  facet_wrap(.~race)+
  xlab("Age")+
  ylab("Number of profiles")+
  ggtitle("Demographic breakdown of study Twitter profiles", subtitle = "Ethnicity: 14% African, 17% Asian, 53% Caucasian, 16% Latino, n = 177,052\nGender: 38% Female, 62% Male, n = 135,708")+
  scale_y_continuous(labels = c("10,000", "5,000", "0", "5000", "10,000"), breaks = c(-10000, -5000, 0, 5000, 10000), limits = c(-15000, 10000))+
  scale_x_continuous(breaks = c(10, 20, 30, 40, 50, 60), labels = c("10-19", "20-29", "30-39", "40-49", "50-59", "60-69"), limits = c(5, 70))
