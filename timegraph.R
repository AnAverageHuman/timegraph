#!/usr/bin/Rscript

library(argparse)
library(ggplot2)

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
  data$date <- as.Date(data$date, format = "%m/%d")
  data$hours <- data$end - data$start
  data
}

get_averages <- function(df) {
  aggregate(df$hours, list(week = df$week), mean)
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
create_scatterplot <- function(df, w_avg) {
  ggplot(df, aes(x = date, y = hours, color = factor(week))) +
  theme(axis.text.x = element_text(angle = 30, vjust = 1, hjust = 1)) +
  geom_point() +
  geom_smooth(inherit.aes = FALSE, se = FALSE, aes(x = date, y = hours)) +
  geom_hline(aes(color = factor(week), yintercept = df$w_avg)) +
  geom_hline(aes(color = "black", yintercept = mean(df$hours))) +
  scale_color_discrete(name   = "Average",
                       labels = c(paste("Week", w_avg$week), "Total")) +
  theme(legend.position = "bottom")
}

if (! interactive()) {
  args <- parse_arguments()
  df <- parse_csv(args$file)
  w_avg <- get_averages(df)
  df$w_avg <- rep(w_avg$x, table(df$week))
  ggsave("bars.png", plot = create_bargraph(df))
  ggsave("averages.png", plot = create_scatterplot(df, w_avg))
}
