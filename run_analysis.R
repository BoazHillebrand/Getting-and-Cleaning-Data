# Extract and process the UCI "Human Activity Recognition Using Smartphones" dataset
#
# Submitted In Partial Completion of Coursera Data Science Specialization Coursework
# Author: Boaz Hillebrand

# Install/load required packages

if(!require(readr)){
        install.packages("readr")
        library(readr)
}

if(!require(data.table)){
        install.packages("data.table")
        library(data.table)
}

# Combine the Train and Test datasets

x.train <- read_table("UCI HAR Dataset/train/x_train.txt", col_names = F)
y.train <- read_table("UCI HAR Dataset/train/y_train.txt", col_names = F) #Labels
sub.train <- read_table("UCI HAR Dataset/train/subject_train.txt", col_names = F) #Subject

x.test <- read_table("UCI HAR Dataset/test/x_test.txt", col_names = F)
y.test <- read_table("UCI HAR Dataset/test/y_test.txt", col_names = F) #Labels
sub.test <- read_table("UCI HAR Dataset/test/subject_test.txt", col_names = F) #Subject

training <- cbind(x.train, y.train, sub.train)
testing <- cbind(x.test, y.test, sub.test)

dat <- rbind(training, testing)

# Clean up workspace

rm(x.test, x.train, y.test, y.train, sub.test, sub.train, testing, training)

# Assign variable names to data

names(dat) <- c(unlist(read_delim("UCI HAR Dataset//features.txt", delim = " ", col_names = F)[,2]),"activity_type", "subject")

# Get relevant subset of dataset

dat <- dat[ ,grep("mean|std|activity|subject", colnames(dat))]
dat <- dat[ ,!grepl("meanFreq", colnames(dat))]

# Clean up variable names

names(dat) <- gsub("()", "", names(dat), fixed = T)
names(dat) <- gsub("^t","Time_",names(dat))
names(dat) <- gsub("^f","Frequency_",names(dat))
names(dat) <- gsub("Acc", "_Accelerometer_", names(dat))
names(dat) <- gsub("Gyro", "_Gyrometer_", names(dat))
names(dat) <- gsub("BodyBody", "Body_", names(dat))
names(dat) <- gsub("Mag", "_Magnitude", names(dat))
names(dat) <- gsub("std", "std.dev", names(dat))
names(dat) <- gsub("-", "_", names(dat))
names(dat) <- gsub("__", "_", names(dat))

# Assign relevant labels to activity values

dat$activity_type[dat$activity_type == 1] <- "walking"
dat$activity_type[dat$activity_type == 2] <- "walking_upstairs"
dat$activity_type[dat$activity_type == 3] <- "walking_downstairs"
dat$activity_type[dat$activity_type == 4] <- "sitting"
dat$activity_type[dat$activity_type == 5] <- "standing"
dat$activity_type[dat$activity_type == 6] <- "laying"

# Create tidy dataset

dat <- as.data.table(dat)
tidy.dat <- dat[, lapply(.SD, mean), by = .(activity_type, subject)]

# Save data to .csv files

write_csv(dat, "UCI_HAR_Data.csv")
write_csv(tidy.dat, "UCI_HAR_Tidy.csv")
