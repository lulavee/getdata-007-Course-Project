library("dplyr")
library("reshape2")

getDataFrame <- function(kind){
        result <- list()
        result$sid <- read.table(file = sprintf("UCI HAR Dataset/%s/subject_%s.txt", kind,kind), header=F)
        result$x   <- read.table(file = sprintf("UCI HAR Dataset/%s/X_%s.txt", kind,kind), header=F)
        result$y   <- read.table(file = sprintf("UCI HAR Dataset/%s/y_%s.txt", kind,kind), header=F)
        
        result$bodyAccX <- read.table(file = sprintf("UCI HAR Dataset/%s/Inertial Signals/body_acc_x_%s.txt", kind,kind), header=F)
        result$bodyAccY <- read.table(file = sprintf("UCI HAR Dataset/%s/Inertial Signals/body_acc_y_%s.txt", kind,kind), header=F)
        result$bodyAccZ <- read.table(file = sprintf("UCI HAR Dataset/%s/Inertial Signals/body_acc_z_%s.txt", kind,kind), header=F)
        
        result$bodyGyroX <- read.table(file = sprintf("UCI HAR Dataset/%s/Inertial Signals/body_gyro_x_%s.txt", kind,kind), header=F)
        result$bodyGyroY <- read.table(file = sprintf("UCI HAR Dataset/%s/Inertial Signals/body_gyro_y_%s.txt", kind,kind), header=F)
        result$bodyGyroZ <- read.table(file = sprintf("UCI HAR Dataset/%s/Inertial Signals/body_gyro_z_%s.txt", kind,kind), header=F)
        
        result$totalAccX <- read.table(file = sprintf("UCI HAR Dataset/%s/Inertial Signals/total_acc_x_%s.txt", kind,kind), header=F)
        result$totalAccY <- read.table(file = sprintf("UCI HAR Dataset/%s/Inertial Signals/total_acc_y_%s.txt", kind,kind), header=F)
        result$totalAccZ <- read.table(file = sprintf("UCI HAR Dataset/%s/Inertial Signals/total_acc_z_%s.txt", kind,kind), header=F)
        
        result
}

setwd("~/Documents/Investigacion/Data Science/Getting and Cleaning data /Course project/")
##Solving 1
        #Merges the training and the test sets to create one data set.
        #getting the test dataframe. dsTest stands for dataset Test
        dsTest <- getDataFrame("test")
        dsTest <- tbl_df(data.frame(dsTest))
        #getting the test dataframe. dsTrain stands for dataset Train
        dsTrain <- getDataFrame("train")
        dsTrain <- tbl_df(data.frame(dsTrain))
        
        #union both datasets
        ds <- union(dsTest, dsTrain)
                
        #removing previous 
        rm(dsTest)
        rm(dsTrain)
##solved 1! in ds is the full merging have the 

# 3. Uses descriptive activity names to name the activities in the data set
ds <- mutate(ds, activity = V1.1) %>% select(-V1.1)
ds <- mutate(ds, sid = V1) %>% select(-V1)

activity <- read.table("UCI HAR Dataset/activity_labels.txt")
activity <- tbl_df(activity)

activity <- activity %>% mutate(activity = V1, activityDes = V2) %>% select (-V1, -V2)
ds<- inner_join(ds, activity) 

## Solving 2
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
metadata <- read.table("UCI HAR Dataset//features.txt")      
metadata <- tbl_df(metadata)

indices <- metadata %>% filter(str_detect(V2, "mean|std")) %>% filter(!str_detect(V2, "meanFreq"))

# 4. Appropriately labels the data set with descriptive variable names. 
names(ds)[indices$V1] <- as.character(indices$V2)
ds<- select(ds, sid, activityDes, indices$V1)


# 5. From the data set in step 4, creates a second, independent tidy data set with 
# the average of each variable for each activity and each subject.

tidyHomework <- melt(ds, id.vars = c("sid", "activityDes"),
                            variable.name = "variable", 
                            value.name = "value")

tidyAvg <- tidyHomework 
        %>% group_by(sid, activityDes, variable) 
        %>% summarise(mean = mean(value))

names(tidyAvg) <- c("Subject", "Activity", "Variable", "Mean")
write.csv(tidyAvg, file = "resultsMeanValues")
