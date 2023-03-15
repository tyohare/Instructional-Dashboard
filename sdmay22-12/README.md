# Project Overview

Instructional Dashboard for visualizing classroom interconnectivity

## Getting Started

### Dependencies

R - 4.1.1 or greater  
RStudio

### Development

Start by cloning the repository to your local machine
```
git clone https://git.ece.iastate.edu/sd/sdmay22-12.git
```

### Executing program

1. Open the .Rproj file in RStudio, 
2. Open either src/ui.R or src/server.R in the editor
3. Hit **Run App**

### MS SQL ODBC Driver

When running locally, you will need to install and specify an ODBC driver in order to connect to the MS SQL database. I recommend the **ODBC Driver 17 for SQL Server**.

Windows -> [ODBC Driver 17](https://go.microsoft.com/fwlink/?linkid=2187214)  
MacOS -> [ODBC Driver 17](https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/install-microsoft-odbc-driver-sql-server-macos?view=sql-server-ver15)

Once downloaded, navigate to src/db.R and change the "Driver" parameter to "ODBC Driver 17 for SQL Server"

## Help

[Mastering Shiny](https://mastering-shiny.org/index.html)

