

#tasks in this script code
#the structure person_id, city, type_of_broadband_connection, name_of_isp, average_download_speed, average_upload_speed
#has 1 line per person (i.e. calculate a single average download and upload speed for each person)
#only contains people in the cities 'Samsville' and 'Databury'
#only contains download and upload measurements which have run successfully (i.e. put a filter on did_test_complete_successfully)
#only contains tests from the month of January 2021 (i.e. put a filter on time_of_measurement).





#data import
Dspeed_measure <- read.csv("download_speed_measurements.csv")
Uspeed_measure <- read.csv("upload_speed_measurements.csv")
person_details <- read.csv("details_for_each_person.csv")



#some measured speed data was 0 I assume that it means some disconnectivity and the network does not work in this time and I did not delete these data

library(data.table)
library(dplyr)
#only contains download and upload measurements which have run successfully (i.e. put a filter on did_test_complete_successfully)
Dspeed_measure <- data.table(na.omit(Dspeed_measure))
Uspeed_measure <- data.table(na.omit(Uspeed_measure))


# we only need year & month & day

library(data.table)
replace <- as.character(Dspeed_measure$time_of_measurement)
replace <- sub("T.*", "", replace)
Dspeed_measure[,"time_of_measurement"] <- replace
Dspeed_measure <- setDT(Dspeed_measure)[time_of_measurement %between% c('2021-01-01', '2021-01-31')]


replace <- as.character(Uspeed_measure$time_of_measurement)
replace <- sub("T.*", "", replace)
Uspeed_measure[,"time_of_measurement"] <- replace
Uspeed_measure <- setDT(Uspeed_measure)[time_of_measurement %between% c('2021-01-01', '2021-01-31')]




#has 1 line per person (i.e. calculate a single average download and upload speed for each person)
Dspeed_measure <- Dspeed_measure[,mean(measured_download_speed_in_Mbps), by = person_id]
Uspeed_measure <- Uspeed_measure[,mean(measured_upload_speed_in_Mbps), by = person_id]




#joining tables

New_person_detail <- merge(x = person_details, y = Dspeed_measure, by = "person_id", all.x = TRUE)
colnames(New_person_detail)[5] <- "average_download_speed"

New_person_detail <- merge(x = New_person_detail, y = Uspeed_measure, by = "person_id", all.x = TRUE)
colnames(New_person_detail)[6] <- "average_upload_speed"

#only contains people in the cities 'Samsville' and 'Databury'
New_person_detail <- New_person_detail[New_person_detail$city %in% c("Databury","Samsville"),]


write.csv(New_person_detail,"out.csv", row.names = FALSE)