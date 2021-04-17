library(arules)
library(arulesViz)
library(plyr)

groceries=read.csv("Groceries_dataset.csv")

#### Step 1: Transform data into a format for Apriori algorithm ####

# sort transactions by member number and transform to proper format
groceries.sorted = groceries[order(groceries$Member_number),]
str(groceries.sorted)

groceries.sorted$Member_number = as.numeric(groceries.sorted$Member_number)

# transform the data from data frame to transactions
groceries.itemList = ddply(groceries.sorted,c("Member_number","Date"), 
                           function(df1)paste(df1$itemDescription,  # for each split, we want to paste all the item descriptions tgt for 1 member num and date
                                              collapse = ","))

View(groceries.itemList)

groceries.itemList = groceries.itemList[,3]
write.csv(groceries.itemList,"ItemList.csv", quote = FALSE, row.names = FALSE)

#### Step 2: Read the transaction data for association rules analysis ####
ItemList = read.transactions(file="ItemList.csv", 
                             rm.duplicates= TRUE, # remove duplicate items 
                             header=TRUE, # cuz our cvs file has a title for the 1st row
                             format="basket", # cuz we have all the items written in 1 single cell/basket
                             sep=",",
                             cols=NULL) # we only have 1 col, we dont have an ID col

summary(ItemList)
# density -> fraction of entries with 1 against 0
# element length dist. -> count how many num of items are in 1 basket/cell
# includes extended ... -> irrelevant to our analysis

# get the plot of the most frequently bought items
itemFrequencyPlot(ItemList, topN = 20) # top 20 most frequently bought items

# visualize the sparse matrix of transactions
image(ItemList[1:200], # visualize the first 200 transactions
      aspect='fill')   # black dots = 1s

#### Step 3: Generate association rules ####
basket.rules = apriori(ItemList,
                       parameter = list(sup = 0.001, # support
                                        conf = 0.1,  # confidence
                                        minlen=2,    # len = num of items in these item sets for the association rule
                                        maxlen=10)); # this limits the max num of itmes we want to see in a basket
                                                     # it is meaningless if we have 30 items in a basket, difficult to obtain insights

summary(basket.rules)
# set of 131 rules -> 131 matching baskets/cells
# rule length dis size = 2 -> buying 1 item will lead to buying another item
# rule length dis size = 3 -> buying 2 items will lead to buying another item
# support median = low -> cuz it is a very sparse data set
# confidence median = low -> means that the association rule formed based on this data set don't have high confidence
# lift median < 1 -> means for most of the rules, if u buy 1 item then u tend to buy less of the other item. Need to choose rules with lift > 1. This means the association isn't that strong.

# have a look at association rules
inspect(basket.rules) # too long
inspect(basket.rules[1:5]) # so just inspect the first 5 rows
                           # if we look at row 2, it has support & confidence above threshold, and a lift > 1, hence, this rule has good quality 
                           # row 2 -> buying seasonal products, will lead to buying rolls or buns

#### Step 4: Result & Analysis ####
inspect(sort(basket.rules, by="lift")[1:10])
# example row 1 -> whole milk + yogurt lead to sausage
# first 3 rows we can see ppl tend to buy whole milk + yogurt + sausage tgt
# so maybe we can put these items tgt in the store.

plot(basket.rules)
# most rules have low confidence (<0.2) and support (<0.004)
# only few rules have high lift (dark red)

# what customers buy before buying whole milk
wholeMilk.rules=apriori(ItemList, parameter = list(supp=0.001, conf=0.1,minlen=2,maxlen=10),
                        appearance = list(default="lhs",rhs="whole milk"))

inspect(wholeMilk.rules)

# customers bought sausage first also bought
sausage.rules=apriori(ItemList, parameter = list(supp=0.001, conf=0.1,minlen=2,maxlen=10),
                      appearance = list(default="rhs",lhs="sausage"))

inspect(sausage.rules)

# get interactive plots
rules=head(basket.rules, n = 10, by = "confidence")
plot(rules, method = "graph",  engine = "htmlwidget")

# size = support value 
# color shades = lift value (large = darker)
