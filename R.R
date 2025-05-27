install.packages("tidyverse")  # Only if you haven't installed it already
library(tidyverse)
library(ggplot2)
library(dplyr)
library(readr)
library(tm)  # For text analysis
library(wordcloud)  # For word clouds

video_games_data <- read_csv("C:/Users/manik/OneDrive/Desktop/New folder/580/data sets/Video_Games_Sales_Mani.csv")

# Labeling missing values in 'Developer' and 'Rating' as 'Unknown'
video_games_data <- video_games_data %>%
  mutate(Developer = ifelse(is.na(Developer), "Unknown", Developer),
         Rating = ifelse(is.na(Rating), "Unknown", Rating))

# Checking the final size of the dataset
final_dataset_size_after_cleaning <- dim(video_games_data)

# Sampling 5 rows from the dataset
df_cleaned_scores_counts_sample <- sample_n(video_games_data, 5)

# Output
final_dataset_size_after_cleaning
df_cleaned_scores_counts_sample

# 1. Correlation Between Critic and User Review Scores (2010-2020)

# Define the major publishers
major_publishers <- c("Electronic Arts", "Activision", "Ubisoft", "Take-Two Interactive")

# Filter data for action games by the major publishers between 2010 and 2020
action_games <- video_games_data %>%
  filter(Genre == "Action",
         Publisher %in% major_publishers,
         Year_of_Release >= 2010,
         Year_of_Release <= 2020) %>%
  mutate(User_Score = as.numeric(User_Score)) # Convert User_Score to numeric
summary(action_games)

# Calculate correlation coefficients for each publisher
correlation_results <- action_games %>%
  group_by(Publisher) %>%
  summarize(Correlation_Coefficient = cor(Critic_Score, User_Score, use = "complete.obs"))

correlation_results

# Create the scatter plot
ggplot(action_games_major_publishers, aes(x=Critic_Score, y=User_Score, color=Platform)) +
  geom_point() +
  ggtitle("Critic Score vs User Score for Action Games by Major Publishers (2010-2020)") +
  xlab("Critic Score") +
  ylab("User Score") +
  theme_minimal() +
  scale_color_viridis_d()


# Create the bar plot
ggplot(correlation_results, aes(x = Publisher, y = Correlation_Coefficient, fill = Publisher)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Correlation Between Critic and User Scores by Publisher (2010-2020)",
       x = "Publisher",
       y = "Correlation Coefficient") +
  coord_flip()  # Flips the axes for better readability



# 2. Median Global Sales of Super Mario Games

# Filter for Super Mario games and categorize by generation
super_mario_games <- video_games_data %>%
  filter(grepl("Super Mario", Name)) %>%
  mutate(Generation = ifelse(Year_of_Release < 2000, "Early-Gen", "Later-Gen"))
summary(super_mario_games)

# Calculate median sales
median_sales <- super_mario_games %>%
  group_by(Generation) %>%
  summarize(Median_Global_Sales = median(Global_Sales, na.rm = TRUE))

median_sales
summary()
# Colors for the generations
colors <- c("Early-Gen" = "red", "Later-Gen" = "blue")

# Plot with thinner bars
ggplot(median_sales, aes(x=Generation, y=Median_Global_Sales, fill=Generation)) +
  geom_bar(stat="identity", color="black", width=0.5, show.legend = FALSE) + # Adjusted bar width here
  scale_fill_manual(values=colors) +
  ggtitle("Median Global Sales of Super Mario Games by Generation") +
  xlab("Generation") +
  ylab("Median Global Sales (Millions)") +
  theme_minimal() +
  theme(axis.text=element_text(size=12), 
        axis.title=element_text(size=14), 
        plot.title=element_text(size=16, hjust = 0.5))



# 4. Distribution of User Review Scores (2013-2023)

# Filter data for RPG, Action, and Adventure games released between 2013 and 2023 for PlayStation and Xbox
recent_games <- video_games_data %>%
  filter(Genre %in% c('Role-Playing', 'Action', 'Adventure'),
         Year_of_Release >= 2013,
         Year_of_Release <= 2023,
         grepl('PS|Xbox', Platform)) %>%
  mutate(User_Score = as.numeric(User_Score)) # Convert User_Score to numeric
recent_games
summary(recent_games)

# Calculate statistical summaries for recent games
stat_summaries <- recent_games %>%
  summarise(
    Average_User_Score = mean(User_Score, na.rm = TRUE),
    Median_User_Score = median(User_Score, na.rm = TRUE),
    Min_User_Score = min(User_Score, na.rm = TRUE),
    Max_User_Score = max(User_Score, na.rm = TRUE),
    Count = n()
  )

stat_summaries


# Visualization: Boxplot to compare user review scores
ggplot(recent_games, aes(x=Genre, y=User_Score, fill=Platform)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title='User Review Scores for RPG and Action/Adventure Games (Last 10 Years, PlayStation/Xbox)',
       x='Genre',
       y='User Score')


#Question 5 Calculate the average sales figures in different regions for each genre and platform.

# Sales Summary
sales_summary <- video_games_data %>%
  group_by(Genre, Platform) %>%
  summarise(
    Avg_NA_Sales = mean(NA_Sales, na.rm = TRUE),
    Avg_EU_Sales = mean(EU_Sales, na.rm = TRUE),
    Avg_JP_Sales = mean(JP_Sales, na.rm = TRUE),
    Avg_Other_Sales = mean(Other_Sales, na.rm = TRUE)
  )
sales_summary
summary(sales_summary)

# Critic and User Score Summary
score_summary <- video_games_data %>%
  group_by(Genre, Platform) %>%
  summarise(
    Avg_Critic_Score = mean(Critic_Score, na.rm = TRUE),
    Avg_User_Score = mean(as.numeric(User_Score), na.rm = TRUE)
  )
score_summary
summary(score_summary)

# Count Summary
count_summary <- video_games_data %>%
  group_by(Genre, Platform) %>%
  summarise(Game_Count = n())
count_summary
summary(count_summary)

# Viewing the first few rows of each summary
head(sales_summary)
head(score_summary)
head(count_summary)


# Filter for Action games
action_games <- video_games_data %>%
  filter(Genre == 'Action')

# Reshaping the data
action_games_melted <- action_games %>%
  pivot_longer(cols = c(NA_Sales, EU_Sales, JP_Sales, Other_Sales), names_to = 'Region', values_to = 'Sales') %>%
  mutate(Region = gsub('_Sales', '', Region))
action_games_melted
# Creating the stacked bar plot
ggplot(action_games_melted, aes(x = Platform, y = Sales, fill = Region)) +
  geom_bar(stat = 'identity', position = 'stack') +
  scale_fill_viridis_d() +
  theme_minimal() +
  labs(title = "Average Sales of Action Games in Different Regions by Platform (Stacked Bar Plot)",
       x = "Platform",
       y = "Average Sales") +
  theme(legend.position = "right")


# Univariate Analyses - Genre
# Nominal Data (Genre, Publisher)

# Create a table of genre counts
genre_counts <- table(video_games_data$Genre)
genre_counts

# Create a bar plot
ggplot(data = as.data.frame(genre_counts), aes(x = Var1, y = Freq)) +
  geom_bar(stat = "identity", fill = "blue") +
  xlab("Genre") +
  ylab("Count") +
  theme_minimal() +
  ggtitle("Distribution of Video Game Genres")



#Ordinal Data (ESRB Ratings)
# Assuming ESRB Ratings are in a column named 'Rating'
rating_counts <- table(video_games_data$Rating)
ggplot(data = as.data.frame(rating_counts), aes(x = Var1, y = Freq)) +
  geom_bar(stat = "identity", fill = "green") +
  xlab("Rating") +
  ylab("Count") +
  theme_minimal()+
  ggtitle("Distribution of ESRB Rating")

# Ratio Data (Sales, Scores)
# Histogram for Global Sales

ggplot(video_games_data, aes(x = Global_Sales)) +
  geom_histogram(binwidth = 1, fill = "red") +
  xlab("Global Sales (Millions)") +
  ylab("Frequency") +
  theme_minimal() +
  ggtitle("Distribution of Global Sales in Millions")


#Multivariate Analyses
#Correlation Analysis (Critic Scores vs. User Scores)
#Scatterplot for Critic Score vs User Score
ggplot(video_games_data, aes(x = Critic_Score, y = User_Score, color = Genre)) +
  geom_point() +
  labs(title = "Critic Score vs. User Score by Genre",
       x = "Critic Score",
       y = "User Score")

#Regression Analysis
# Simple linear regression: Global Sales based on Critic Score
fit <- lm(Global_Sales ~ Critic_Score, data = video_games_data)
summary(fit)


#As the data set does not contain NLP is not possible. The below code can be executed if the data set has a column review
# NLP Analysis Example: Word Cloud for Game Descriptions
install.packages("syuzhet")
library(syuzhet)

# Sample text data
text_data <- video_games_data$Review

# Text cleaning and sentiment analysis
corpus <- Corpus(VectorSource(text_data))
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removeWords, stopwords("english"))
sentiments <- get_nrc_sentiment(corpus)

# Aggregating sentiment scores
sentiment_scores <- colSums(as.matrix(sentiments))
barplot(sentiment_scores, las = 2, col = rainbow(10))





