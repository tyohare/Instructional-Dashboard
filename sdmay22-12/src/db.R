#########
# Author: sdmay22-12 Team
#
# db: Contains the database connection to our SQL Server
#########

library(odbc)
library(DBI)

getDBConnection <- function() {
  con <- dbConnect(odbc::odbc(), 
            Driver = "ODBC Driver 17 for SQL Server",
            Server = "10.29.163.8",
            Database = "sdmay22_12",
            UID = "SA",
            PWD = "bjum9RPz6=Us",
            Port = 1433)
  print("Successfully connected to database!...")
  return(con)
}
