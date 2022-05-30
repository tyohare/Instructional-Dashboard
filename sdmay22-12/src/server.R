#########
# Author: sdmay22-12 Team
#
# UI of application. All server components are descendants of this file
#########

source('db.R')
source('survey_select/survey_select_module.R')
source('network_graph/network_graph_module.R')
source('survey_import/survey_import_module.R')
source('grade_histogram/grade_histogram_module.R')

flag <- 0

shinyServer(function(input, output, session) {
  # Get database connection
  con <- getDBConnection() 
  
  users <- getUsers(con = con)
  sodiumPassword <- sapply(users[c(2)],sodium::password_store)
  users$passKey <- sodiumPassword
 

  # Shiny login
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = users,
    user_col = userKey,
    pwd_col = passKey,
    sodium_hashed = TRUE,
    log_out = reactive(logout_init()),
    flag <- 1
  )
  
  # Shiny Logout
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth),
    if(flag == 1){
      session$reload()
    }
  )
  
  
  
  # Check that a user is authenticated before displaying anything
  observe({
    if(credentials()$user_auth) {
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
      toggle("idx")
      toggle("idx2")
      toggle("idx3")
      
      
      
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
      toggle("idx")
      toggle("idx2")
      toggle("idx3")
      
    }
  })
  
  #Authenticate and display the sidebar
  output$sidebar <- renderMenu({
    req(credentials()$user_auth)
    sidebarMenu(
      menuItem("Dashboard", tabName = "tab_dashboard"),
      menuItem("Upload Surveys", tabName = "tab_upload"),
      menuItem("About", tabName = "tab_about"),
      menuItem("Contact Information", tabName = "tab_contact")
    )
  })
  
  #Authenticate and display the dashboard
  output$tab_dashboard_ui <- renderUI({
    req(credentials()$user_auth)
    SurveySelectUI("surveySelect")
    NetworkGraphUI("networkGraph")
  })
  
  #Authenticate and display the upload page
  output$tab_upload_ui <- renderUI({
    req(credentials()$user_auth)
    SurveyImportUI("surveyImport")
  })
  
  #Authenticate and display the about page
  output$tab_about_ui <- renderUI({
    req(credentials()$user_auth)
    AboutPageUI()
  })
  
  
  surveyId <- SurveySelectServer("surveySelect", con = con)
  files <- SurveyImportServer("surveyImport", con = con)
  NetworkGraphServer("networkGraph", surveyIdentity = surveyId, con = con, files = files)
  GradeHistogramServer("grade_hist", surveyIdentity = surveyId, con = con, files = files)
  DataTableServer("data_table", surveyIdentity = surveyId, con = con, files = files)

})

# Get unique identifiers from database
getUsers <- function(con) {
  users <- dbGetQuery(con, "Select * from dbo.users")
  print("Got identifiers")
  return(users)
}