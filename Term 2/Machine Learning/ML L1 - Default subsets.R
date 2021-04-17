# %% setup ----
#load data
Default = read.table("Default.txt", header=TRUE)

# summary of dataset
str(Default)

# change character to factor variable
Default$default <- as.factor(Default$default)
Default$student <- as.factor(Default$student)

# %% select the first 50 default=No and the first 50 default=Yes ----

# get the first 50 default = No
default_no_all = Default[Default$default=="No",]
default_no_50_1 = default_no_all[1:50,]

# alternatively, try
default_no_50_2 = Default[Default$default=="No",][1:50,]

# check whether default_no_50_1 is equivalent to default_no_50_2 by yourself
sum(default_no_50_1[,3] != default_no_50_2[,3])
sum(default_no_50_1[,3] == default_no_50_2[,3])
default_no_50 = default_no_50_2

# get the first 50 default=Yes
default_yes_50 = Default[Default$default=="Yes",][1:50,]

# combine default_no_50 and default_yes_50 to get the subset
default_50 = rbind(default_no_50,default_yes_50)


# %% random sampling ----
set.seed(375) # make the random sampling reproducible

default_no_rand=Default[sample(which(Default$default=="No"),50),]
default_yes_rand=Default[sample(which(Default$default=="Yes"),50),]

default_rand = rbind(default_no_rand,default_yes_rand)

set.seed(375) # make the random sampling reproducible

default_no_rand=Default[sample(which(Default$default=="No"),50),]
default_yes_rand=Default[sample(which(Default$default=="Yes"),50),]

default_rand = rbind(default_no_rand,default_yes_rand)