#########
# Author: sdmay22-12 Team
#
# Contact Info Module: Contains contact information for getting in touch with
# Rachel, Michael, and future developers
#########

ContactInfoUI <- function() {
  fluidPage(
    
    titlePanel(
      h1("Contact Information", align="center")
    ),
    
    fluidRow(
      box(
        title = "Rachel Smith", 
        width = NULL, 
        solidHeader = TRUE, 
        status = "danger",
        collapsible = TRUE,
        p(strong("Email: "), tags$a(href="mailto:rsmith2@iastate.edu", "rsmith@iastate.edu")),
        p(strong("Office Phone: "), "515-294-4466"),
        p(strong("Office: "), "Lagomarcino - 901 Stange Road Ames, IA 50011-1041")
      )
    ),
    fluidRow(
      box(
        title = "Michael Brown", 
        width = NULL, 
        solidHeader = TRUE, 
        status = "danger",
        collapsible = TRUE,
        p(strong("Email: "), tags$a(href="mailto:brownm@iastate.edu", "brownm@iastate.edu")),
        p(strong("Office Phone: "), "515-294-1276"),
        p(strong("Office: "), "2628 Lagomarcino - 901 Stange Road Ames, IA 50011-1041")
      )
    )
  )
}

