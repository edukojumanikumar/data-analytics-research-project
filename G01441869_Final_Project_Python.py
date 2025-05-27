#!/usr/bin/env python
# coding: utf-8

# In[3]:


import pandas as pd
import numpy as np
import matplotlib as mtplib
import seaborn as sns
import matplotlib.pyplot as plt
import plotly.express as px
df=pd.read_csv("Video_Games_Sales_Mani.csv")
print(df)


# In[4]:


# Ensuring that all data in string columns start with a capital letter
# This will be applied to columns like 'Name', 'Platform', 'Genre', 'Publisher', 'Developer', and 'Rating'

columns_to_capitalize = ['Name', 'Platform', 'Genre', 'Publisher', 'Developer', 'Rating']

for col in columns_to_capitalize:
    if col in df.columns:
        df[col] = df[col].str.title()

# Verifying the changes by displaying a few random rows
df.sample(5)


# In[5]:


# Removing rows with missing 'Year_of_Release' data
df_cleaned = df.dropna(subset=['Year_of_Release'])

# Checking the new size of the dataset after removal
new_dataset_size = df_cleaned.shape

new_dataset_size


# In[6]:


# Replacing empty spaces with NaN and then removing rows with NaN in 'Genre' and 'Publisher'
df_cleaned = df_cleaned.dropna(subset=['Genre', 'Publisher'])

# Checking the final size of the dataset after this process for 'Genre' and 'Publisher'
final_dataset_size_genre_publisher = df_cleaned.shape

final_dataset_size_genre_publisher


# In[7]:


# Checking for outliers in sales columns: NA_Sales, EU_Sales, JP_Sales, Other_Sales, and Global_Sales
sales_columns = ['NA_Sales', 'EU_Sales', 'JP_Sales', 'Other_Sales', 'Global_Sales']
sales_outliers = df_cleaned[sales_columns].describe()

sales_outliers


# In[8]:


# Replacing any empty spaces with the most repeated data (mode) specifically for sales columns
sales_columns = ['NA_Sales', 'EU_Sales', 'JP_Sales', 'Other_Sales', 'Global_Sales']

for col in sales_columns:
    mode_value = df_cleaned[col].mode()[0]
    df_cleaned[col] = df_cleaned[col].replace("", mode_value)

# Verifying the changes by displaying a few random rows
df_cleaned[sales_columns].sample(5)


# In[9]:


# Labeling missing values in 'Developer' and 'Rating' as 'Unknown'
df_cleaned['Developer'].fillna('Unknown', inplace=True)
df_cleaned['Rating'].fillna('Unknown', inplace=True)
# Checking the final size of the dataset and a sample of the data after these changes
final_dataset_size_after_cleaning = df_cleaned.shape
df_cleaned_scores_counts_sample = df_cleaned.sample(5)

final_dataset_size_after_cleaning, df_cleaned_scores_counts_sample


# In[10]:


# Replacing 'tbd' with NaN in 'User_Score' and converting it to a numeric type
df_cleaned['User_Score'] = df_cleaned['User_Score'].replace('tbd', float("NaN"))

# Converting 'User_Score' to a numeric type
df_cleaned['User_Score'] = pd.to_numeric(df_cleaned['User_Score'])

# Recomputing the median for 'User_Score'
median_user_score = df_cleaned['User_Score'].median()

# Imputing missing 'User_Score' values with the updated median
df_cleaned['User_Score'].fillna(median_user_score, inplace=True)

# Checking the median value and a sample of the data after the update
median_user_score, df_cleaned['User_Score'].sample(5)

# Checking the new size of the dataset and a sample of the data after imputation
imputed_dataset_size = df_cleaned.shape
df_imputed_sample = df_cleaned.sample(5)

imputed_dataset_size, df_imputed_sample



# In[11]:


# Imputing missing values for 'Critic_Score', 'Critic_Count', 'User_Score', and 'User_Count'

# Calculating median values for each column
median_critic_score = df_cleaned['Critic_Score'].median()
median_critic_count = df_cleaned['Critic_Count'].median()

median_user_count = df_cleaned['User_Count'].median()

# Imputing missing values with the median
df_cleaned_final = df_cleaned.copy()
df_cleaned_final['Critic_Score'].fillna(median_critic_score, inplace=True)
df_cleaned_final['Critic_Count'].fillna(median_critic_count, inplace=True)

df_cleaned_final['User_Count'].fillna(median_user_count, inplace=True)

df_sample = df_cleaned_final.sample(5)
df_sample


# In[12]:


# Display the data types of each column
df_cleaned_final.dtypes



# In[45]:


#plotting


# In[15]:


# 3. Average Scores Across Top 5 Developers
# Filter data for games sold over 10 million copies globally between 2000 and 2020
top_selling_games = df_cleaned[
    (df_cleaned['Global_Sales'] > 10) &
    (df_cleaned['Year_of_Release'] >= 2000) &
    (df_cleaned['Year_of_Release'] <= 2020)
]

# Group by developer and count the number of games
top_developers = top_selling_games.groupby('Developer').size().sort_values(ascending=False)

# Selecting the top 5 developers
top_5_developers = top_developers.head(5)

top_5_developers
top_selling_games.describe()



# In[51]:


# Extracting data for the top 5 developers
top_5_dev_data = top_selling_games[top_selling_games['Developer'].isin(top_5_developers.index)]

# Analyzing common characteristics such as genres, platforms, and ratings
common_characteristics = top_5_dev_data.groupby('Developer').agg({
    'Genre': lambda x: x.mode()[0],  # Most common genre
    'Platform': lambda x: x.mode()[0],  # Most common platform
    'Rating': lambda x: x.mode()[0]  # Most common rating
})

common_characteristics



# In[53]:


import seaborn as sns
import matplotlib.pyplot as plt

# Counting occurrences of each category
genre_counts = top_5_dev_data['Genre'].value_counts()
platform_counts = top_5_dev_data['Platform'].value_counts()
rating_counts = top_5_dev_data['Rating'].value_counts()

# Set up the matplotlib figure
fig, axes = plt.subplots(3, 1, figsize=(10, 15))

# Bar plot for common genre
sns.barplot(x=genre_counts.values, y=genre_counts.index, ax=axes[0], palette='viridis')
axes[0].set_title('Most Common Genre by Top Developer')
axes[0].set_xlabel('Count')
axes[0].set_ylabel('Genre')

# Bar plot for common platform
sns.barplot(x=platform_counts.values, y=platform_counts.index, ax=axes[1], palette='viridis')
axes[1].set_title('Most Common Platform by Top Developer')
axes[1].set_xlabel('Count')
axes[1].set_ylabel('Platform')

# Bar plot for common rating
sns.barplot(x=rating_counts.values, y=rating_counts.index, ax=axes[2], palette='viridis')
axes[2].set_title('Most Common Rating by Top Developer')
axes[2].set_xlabel('Count')
axes[2].set_ylabel('Rating')

# Adjust layout
plt.tight_layout()
plt.show()


# In[57]:


# Analyzing the effect of regional differences in user preferences on sales and critical reception
# Grouping data by Genre and Platform to analyze regional sales and critical reception
regional_analysis = df_cleaned.groupby(['Genre', 'Platform']).agg({
    'NA_Sales': 'mean',  # Average sales in North America
    'EU_Sales': 'mean',  # Average sales in Europe
    'JP_Sales': 'mean',  # Average sales in Japan
    'Other_Sales': 'mean',  # Average sales in other regions
    'Critic_Score': 'mean',  # Average critic score
    'User_Score': lambda x: pd.to_numeric(x, errors='coerce').mean()  # Average user score
}).reset_index()

# Displaying the first few rows of the aggregated data
regional_analysis.head()



# In[ ]:




