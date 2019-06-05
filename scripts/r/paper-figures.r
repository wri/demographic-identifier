library(ggplot2)
twitter <- read.csv("data/processed/twitter_change.csv")
ggplot(data = twitter, aes(x=reorder(Account, Gain), y = Gain))+
  geom_col(aes(fill=Type))+
  facet_wrap(.~Gain.Type, scales = "free")+
  coord_flip()+
  theme_minimal()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.text.x = element_text(angle = 90))+
  scale_fill_wsj(palette = "rgby")+
  xlab("")+
  ggtitle("Absolute and multiple change in Twitter followers")


facebook <- read.csv("data/processed/facebook_daily_shares.csv")
facebook$total <- rowSums(facebook)
facebook$date <- seq(ymd('2018-08-21'),ymd('2018-09-16'),by='day')
diffs <- diff(facebook$total)
diffs <- c(1764, diffs)
facebook$new <- diffs

rects <- data.frame(xstart = decimal_date(ymd('2018-08-23')), 
                    xend = decimal_date(ymd('2018-08-31')))

all_files$date <- floor_date(strptime(all_files$created_at, "%a %b %d %H:%M:%S %z %Y"), unit = "day")
all_files$date <- as.character(all_files$date)

twitter_stats <- all_files %>%
  group_by(as.character(date)) %>%
  summarise(n = n())
facebook$date <- as.character(facebook$date)
colnames(twitter_stats) <- c("date", "Twitter")


time_stats <- data.frame(date = facebook$date, facebook = facebook$new)
time_stats <- left_join(time_stats, twitter_stats)

ggplot(data = time_stats[-27,], aes(x = ymd(date), y = facebook))+
  annotate("rect", fill = "black", alpha = 0.2, 
           xmin = ymd('2018-08-29'), xmax = ymd('2018-08-31'),
           ymin = -Inf, ymax = Inf)+
  geom_line(aes(color = "Facebook"))+
  geom_line(aes(y = Twitter, color = "Twitter"))+
  theme_bw()+
  xlab("")+
  ylab("Daily engagement")+
  scale_x_date(date_minor_breaks = "day")+
  scale_color_brewer(palette = "Set1")+
  theme(legend.title=element_blank(), legend.position = "bottom", axis.title.x = element_blank())+
  ggtitle("Daily engagement metrics for Twitter and Facebook")

glf_comparison <- read.csv("data/processed/glf-comparison.csv")
glf_comparison <- glf_comparison %>% group_by(Continent) %>% mutate(mean = mean(Percent))

ggplot(data = glf_comparison, aes(x = reorder(Continent, mean), y = Percent))+
  geom_col(aes(fill = Conference), position = "dodge")+
  coord_flip()+
  theme_bw()+
  scale_fill_brewer(palette = "Set1")+
  xlab("")+
  ylab("User percentage")+
  ggtitle("Tweet locations during GLF Bonn and Nairobi")+
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank())
