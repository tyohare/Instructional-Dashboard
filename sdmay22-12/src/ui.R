#########
# Author: sdmay22-12 Team
#
# UI of application. All UI components are descendants of this file
#########

library(shiny)
library(shinydashboard)
library(shinyauthr)
library(shinyjs)


source('survey_select/survey_select_module.R')
source('network_graph/network_graph_module.R')
source('survey_import/survey_import_module.R')
source('about_page/about_page_module.R')
source('grade_histogram/grade_histogram_module.R')
source('data_table/data_table_module.R')
source('contact_info/contact_info_module.R')

shinyUI(
  
  fluidPage(
    # Dashboard
    dashboardPage(
      title = "Instructional Dashboards",
      skin  = c("red"),
      dashboardHeader(
        title = "Instructional Dashboards",
        tags$li(class = "dropdown", style = "padding: 8px;", shinyauthr::logoutUI("logout"))
        
        
      ),
      
      # Sidebar
      dashboardSidebar(
        collapsed = TRUE, sidebarMenuOutput("sidebar")
        
      ),

            # Body
      dashboardBody(
        #Authenticate before displaying
        shinyauthr::loginUI(id = "login"),
        collapsed = TRUE,
        
        tabItems(
          tabItem(tabName = "tab_dashboard",
                  useShinyjs(),
                  div(id = "idx3",SurveySelectUI("surveySelect")),
                  div(id = "idx2",NetworkGraphUI("networkGraph")),
                  fluidRow(
                    column(5,div(id = "idx",GradeHistrogramUI("grade_hist"))), 
                    column(7, DataTableUI("data_table")),
                  )
                  
                  
          ),
          tabItem(tabName = "tab_upload",
                  SurveyImportUI("surveyImport")
          ),
          tabItem(tabName = "tab_about",
                  AboutPageUI()
          ), 
          tabItem(tabName = "tab_contact",
                  ContactInfoUI()
          )
        )
      )
      
    )
  ) 
)
