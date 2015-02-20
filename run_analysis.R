library(plyr)

# -- prepare the raw data

# check if a data folder exists; if not then create one
if (!file.exists("data")) {dir.create("data")}

# download the file & unzip
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, "./data/project_activity.zip")
unzip("./data/project_activity.zip", exdir = "./data/project_activity")

# read in the data for test
test <- read.table("./data/project_activity/UCI HAR Dataset/test/X_test.txt")
testLabel <- read.table("./data/project_activity/UCI HAR Dataset/test/Y_test.txt")
testSubject <- read.table("./data/project_activity/UCI HAR Dataset/test/subject_test.txt")

# read in the data for training
training <- read.table("./data/project_activity/UCI HAR Dataset/train/X_train.txt")
trainingLabel <- read.table("./data/project_activity/UCI HAR Dataset/train/Y_train.txt")
trainingSubject <- read.table("./data/project_activity/UCI HAR Dataset/train/subject_train.txt")

# read in the data for label
activityLabel <- read.table("./data/project_activity/UCI HAR Dataset/activity_labels.txt")
features <- read.table("./data/project_activity/UCI HAR Dataset/features.txt")

# -- begin analysis
#Step 0 - Relabel the names of columns 
names(test) <- features$V2; names(training) <- features$V2
names(testLabel) <- "activity"; names(trainingLabel) <- "activity"
names(testSubject) <- "subject"; names(trainingSubject) <- "subject"

#Step 1 - Merges the training and the test sets to create one data set.
OneDS <- rbind(test, training)

#Step 2 - Extracts only the measurements on the mean and standard deviation for each measurement. 
CombinedLabel <- rbind(testLabel, trainingLabel)
CombinedSubject <- rbind(testSubject, trainingSubject)

OneDS_new <- CombinedLabel
OneDS_new <- cbind(OneDS_new, CombinedSubject)

criteria <- grep("mean|std", names(OneDS))
for (each in criteria){
  OneDS_new <- cbind(OneDS_new, OneDS[each])
}

#Step 3 - Uses descriptive activity names to name the activities in the data set
OneDS_new$activity <- mapvalues(OneDS_new$activity, from = levels(factor(OneDS_new$activity)), to = levels(activityLabel$V2))

#Step 4 - Appropriately labels the data set with descriptive variable names. This has been done in 'Step 0- Relabel the names of columns', see above.

#Step 5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
OneDS_tidy <- aggregate(OneDS_new, list(OneDS_new$subject, OneDS_new$activity), mean)
OneDS_tidy$subject <- NULL; OneDS_tidy$activity <- NULL
names(OneDS_tidy)[1] <- "subject"; names(OneDS_tidy)[2] <- "activity"

#Final Step - write out the dataframe into a file
write.table(file = "activitydata.txt", x = OneDS_tidy, row.names = FALSE)