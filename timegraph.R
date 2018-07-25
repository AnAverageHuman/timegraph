#!/usr/bin/Rscript

library(argparse)
library(dplyr)
library(ggplot2)
library(lubridate)

parse_arguments <- function() {
  parser <- ArgumentParser()
  parser$add_argument("file", nargs = 1, help = "file with data")
  args <- parser$parse_args()

  if (! file.exists(args$file)) {
    stop("Data file ", args$file, " does not exist.", call. = FALSE)
  }

  args
}

parse_csv <- function(filename) {
  data <- read.csv(filename)
  data$date <- as.Date(data$date)
  data$week <- week(data$date)
  data$hours <- data$end - data$start
  data
}

get_averages <- function(df) {
  grouped <- df %>% group_by(week = week(date))
  weekly <- grouped %>% summarize(average = mean(hours))
  weekly$weekstart <- unique(floor_date(grouped$date, unit = "week"))
  weekly$weekend <- unique(ceiling_date(grouped$date, unit = "week"))
  weekly
}

# generate floating bar graph using boxplots
create_bargraph <- function(df) {
  ggplot(df, aes(x = date,
                 y = hours,
                 ymin = start,
                 ymax = end,
                 lower = start,
                 upper = end,
                 middle = start,
                 color = hours > mean(hours))) +
    theme(axis.text.x = element_text(angle = 30, vjust = 1, hjust = 1),
          legend.position = "bottom") +
    geom_boxplot(stat = "identity")
}

# generate hours scatterplot
create_scatterplot <- function(df) {
  ggplot(df, aes(x = date, y = hours, color = factor(week))) +
  theme(axis.text.x = element_text(angle = 30, vjust = 1, hjust = 1)) +
  geom_point() +
  geom_smooth(inherit.aes = FALSE, se = FALSE, aes(x = date, y = hours)) +
  geom_segment(aes(x = weekstart,
                   y = average,
                   xend = weekend,
                   yend = average)) +
  geom_hline(aes(color = "black", yintercept = mean(hours))) +
  scale_color_discrete(name   = "Average",
                       labels = c(paste("Week", 1:length(unique(df$week))),
                                  "Total")) +
  theme(legend.position = "bottom")
}

if (! interactive()) {
  args <- parse_arguments()
  df <- parse_csv(args$file)
  ggsave("bars.png", plot = create_bargraph(df))

  weekly <- get_averages(df)
  ggsave("averages.png", plot = create_scatterplot(merge(df, weekly)))
}
