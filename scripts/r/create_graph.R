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

'''ggplot(data=figdata, aes(x=age))+
  geom_histogram(aes(fill=pred_gender))+
  facet_wrap(.~race)+
  theme_bw()+
  geom_vline(data=means, aes(xintercept=age), linetype="dashed")+
  scale_x_continuous(breaks=c(seq(10,80,10)))+
  theme(panel.grid.minor.y=element_blank(),
        panel.grid.major.y=element_blank())
'''

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
  theme_bw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.y=element_text(face = bolded),
        legend.position = "none")+
  xlab("")+
  ylab("Percent female")

##### AGE BY TOPIC ######
age <- read.csv("data/processed/age_data.csv")
age <- age %>%
  group_by(name) %>%
  mutate(age_mean = mean(age))

bolded <- rep("plain", 19)
bolded[11] <- "bold"

ggplot(data = age, aes(x=age, y = reorder(name, age_mean)))+
  geom_density_ridges()+
  theme_bw()+
  theme(axis.text.y=element_text(face = bolded))+
  xlab("Age")+
  ylab("")
