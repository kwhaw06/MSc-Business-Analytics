####################
#### Question 3 ####
####################

# load relevant library ####
library(ggplot2)
library(factoextra)
library(dplyr)

## Step 1: Identify missing data 
data <- read.csv("customers.csv")

apply(data, 2, function (x) sum(is.na(x)))

## Step 2: Construct a box plot 
p <- ggplot(stack(data), aes(x = ind, y = values)) + 
  geom_boxplot() + coord_flip()

p <- p + labs(y = "Spending ($USD)", x = "Products")
p

## Step 3: Remove the outliers 
processed_data = data

for (i in colnames(data)){
  # Assign the outlier values into a vector
  outliers <- boxplot(data[[i]], plot=FALSE)$out
  
  # Remove the rows containing the outliers
  processed_data <- processed_data[-which(processed_data[[i]] %in% outliers),]
}

## Step 4: Scree plot
fviz_nbclust(processed_data, FUN = hcut, method = "wss")

## Step 5: Perform K-means clustering 
# Compute k-means clustering with k = 3
set.seed(123)
km.final <- kmeans(processed_data, 
                   centers = 3, 
                   nstart = 25)  
# indicates the cluster assignment of each observation
kmclust_assign <- km.final$cluster  
# add a "Cluster" column to the result output table
km_segment_customers <- mutate(processed_data, Cluster = kmclust_assign)  

# number of observations in each clusters
table(km_segment_customers$Cluster) 

# Descriptive statistics at the cluster level（pipe)
km_segment_customers %>%
  group_by(Cluster) %>% 
  summarise_all(funs(round(mean(.)))) %>%
  mutate(TotalSpend = rowSums(.[2:7]),   
         ClusterSize = as.integer(c(83,83,166)))  # display the number of consumers in each clusters

km_segment_customers
