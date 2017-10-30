#!/usr/bin/Rscript
library(ggplot2)

data <- read.csv(commandArgs(TRUE)[1])
data$date  <- as.Date(data$date, format = '%m/%d')
data$hours <- data$end - data$start

wAvg <- aggregate(data$hours, list(week = data$week), mean)
data$wAvg <- rep(wAvg$x, table(data$week))

lastDay <- aggregate(date ~ week, data = data, max)

# generate floating bar graph using boxplots
p <-
  ggplot(data,
         aes(x      = date,
             y      = hours,
             ymin   = start,
             ymax   = end,
             lower  = start,
             upper  = end,
             middle = start,
             group  = week,
             color  = hours > mean(hours))) +
  theme(plot.title      = element_text(size   = 20,
                                       face   = "bold",
                                       margin = margin(10, 0, 10, 0),
                                       hjust  = 0.5),
        axis.text.x     = element_text(angle = 30,
                                       vjust = 1,
                                       hjust = 1),
        legend.position = "bottom") +
  geom_boxplot(stat = "identity")

# generate hours scatterplot
q <-
  ggplot(data, aes(x     = date,
                   y     = hours,
                   color = factor(week))) +

  theme(axis.text.x = element_text(angle = 30,
                                   vjust = 1,
                                   hjust = 1)) +
  geom_point() +
  geom_smooth(inherit.aes = FALSE,
              method      = "auto",
              se          = FALSE,
              aes(x       = data$date,
                  y       = data$hours)) +
  geom_hline(aes(color      = factor(week),
                 yintercept = data$wAvg)) +
  geom_hline(aes(color      = "purple",
                 yintercept = mean(data$hours))) +
  scale_color_discrete(name   = "Average",
                       labels = c(paste("Week", wAvg$week), "Total")) +
  theme(legend.position = "bottom")


ggsave("bars.png", plot = p)
ggsave("averages.png", plot = q)
