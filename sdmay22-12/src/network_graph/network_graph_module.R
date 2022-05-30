#########
# Author: sdmay22-12 Team
#
# Network Graph Module: Contains the UI and server code for the network
# graph window which contains 3 tabs of network graphs
#########
library(shiny)
library(egor)
library(sna)
library(ggplot2)
library(DT)
library(igraph)
library(visNetwork)
library(networkD3)

NetworkGraphUI <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    uiOutput(ns('Settings')),
    box(
      width = 12,
      status = "primary",
      uiOutput(ns('Graph'))
    )
  )
}

gradevalue <- function(x) {
  A <- factor(x, levels=c("A+", "A", "A-",
                          "B+", "B", "B-",
                          "C+", "C", "C-",
                          "D+", "D", "D-", "F"))
  values <- c(1, (1/12)*11, 
              (1/12)*10, (1/12)*9, (1/12)*8,
              (1/12)*7, (1/12)*6, (1/12)*5,
              (1/12)*4, (1/12)*3, (1/12)*2, (1/12)*1,0)
  return (values[A])
}
getcolor <- function (df,colname,value) { 
  maxval <- max(df[[colname]], na.rm = TRUE)
  minval <- min(df[[colname]], na.rm = TRUE)
  percent <- (value-minval)/(maxval-minval)
  nanprotect <- minval-maxval
  # view(percent)
  # view(nanprotect)
  if (is.nan(percent)) {
    return (rgb(0,0,0,1))
  }
  return (rgb(1 - percent,percent,0,1))
}

getEdgeList <- function(df, graph){
  print(graph)
  if(graph == "know") {
    el <- select(df, networkCanvasSourceUUID, networkCanvasTargetUUID, networkCanvasEgoUUID, know_strength);
  } else if(graph == "study") {
    el <- select(df, networkCanvasSourceUUID, networkCanvasTargetUUID, networkCanvasEgoUUID, freq_study);
  } else {
    el <- select(df, networkCanvasSourceUUID, networkCanvasTargetUUID, networkCanvasEgoUUID, freq_social);
  }
  colnames(el) <- c("from", "to", "EgoID", "value")
  el$label <- el$value
  el$label <- as.character(el$label) #This is to be able to have labels on edges, might be removable good for testing though.
  elFiltered <- filter(el, el$value > 0)
  return (elFiltered)
}
NetworkGraphServer <- function(id, surveyIdentity, con, files) {
  moduleServer(
    id,
    function(input, output, session) {
      
      
      # Listen on changes to the Survey ID dropdown will need to replace this with db call
      
      observe({
        validate(need(input$scaling, message=FALSE))
        surveyIdentity()
        files()
        updateTextInput(session = session, "tabId", label = surveyIdentity())
        
        print(input$tabs)
        #Load in files into data frames and validate data exists
        #Currently only loads ego graph data which is fine since this will be replaced by sql calls anyway
        #---------------------------------
        performanceData <- dbGetQuery(con, "SELECT * FROM SimulatedCanvasData")
        
        alterData <- dbGetQuery(con, paste0("SELECT * FROM Person WHERE identifier='", surveyIdentity(), "';"))
        
        edgelistKnow <- dbGetQuery(con, paste0("SELECT * FROM KnowStrength WHERE identifier='", surveyIdentity(), "';"))
        edgelistSocial <- dbGetQuery(con, paste0("SELECT * FROM Social WHERE identifier='", surveyIdentity(), "';"))
        edgelistStudy <- dbGetQuery(con, paste0("SELECT * FROM Study WHERE identifier='", surveyIdentity(), "';"))
        
        datacheck <- reactive({validate(
          need(alterData$networkCanvasUUID, 'No attribute aata found, upload new files or make sure there is data from SQL!'),
          need(edgelistKnow$networkCanvasUUID, 'No edge data found, upload new files or make sure there is data from SQL!'),
          need(edgelistSocial$networkCanvasUUID, 'No edge data found, upload new files or make sure there is data from SQL!'),
          need(edgelistStudy$networkCanvasUUID, 'No edge data found, upload new files or make sure there is data from SQL!'),
          need(performanceData$Login.ID, 'No lms data found, upload new files or make sure there is data from SQL!')
        )})
        
        datacheck()
        joinedData <- inner_join(performanceData,alterData, by = c("Login.ID" = "NetID")) %>% rename(NetID = Login.ID)
        gradient = FALSE
        switch (input$coloring,
          "Team" = {
            joinedData$group <- joinedData$Team
            # view(joinedData$group)
          },
          "Class Section" = {
            joinedData$group <- joinedData$Section.y
          },
          "Grade" = {
            joinedData$group <-  gradevalue(joinedData$Grade)
            gradient = TRUE
          },
          "Course Score" = {
            joinedData$group <-  joinedData$Course.Score
            gradient = TRUE
          },
          "Team Size" = {
            counted <- distinct(joinedData,Team,NetID) %>% count(Team)
            joinedData <- left_join(joinedData,counted,by = c("Team" = "Team")) %>% rename (group = n)
            # view(counted)
            gradient = TRUE
          }
        )
        switch (input$scaling,
                "Team" = {
                  joinedData$value <- joinedData$Team
                },
                "Class Section" = {
                  joinedData$value <- joinedData$Section.y
                },
                "Grade" = {
                  joinedData$value <-  gradevalue(joinedData$Grade)
                },
                "Course Score" = {
                  joinedData$value <-  joinedData$Course.Score
                },
                "Team Size" = {
                  counted <- distinct(joinedData,Team,NetID) %>% count(Team)
                  joinedData <- left_join(joinedData,counted,by = c("Team" = "Team")) %>% rename (value = n)
                  # view(counted)
                }
        )
        # view(joinedData)
        cleanData <- distinct(joinedData, networkCanvasUUID, Name, value, group)
        # fix column order
        if (gradient) {
          cleanData$color <- getcolor(cleanData,"group",cleanData$group)
          cleanData <- cleanData[,c("networkCanvasUUID","Name", "value", "group","color")]
          colnames(cleanData) <- c("id", "label","value", "group","color");

        } else {
          cleanData <- cleanData[,c("networkCanvasUUID","Name", "value", "group")]
          colnames(cleanData) <- c("id", "label","value", "group");
        }
        colortitle <- cleanData$group
        scaletitle <- cleanData$value
        if (input$coloring == "Grade"|| input$scaling == "Grade") {
          grades <- distinct(joinedData,networkCanvasUUID,Grade)$Grade
          cleanData$Grade <- grades
          if (input$coloring == "Grade") {
            colortitle <- cleanData$Grade
          } else if (input$scaling == "Grade") {
            scaletitle <- cleanData$Grade
          }
        }
        cleanData$title <- paste(cleanData$label,"<br>",input$scaling,scaletitle,"<br>",input$coloring,colortitle)
        view(cleanData)
        cleanKnowEl <- getEdgeList(edgelistKnow, "know");
        cleanSocialEl <- getEdgeList(edgelistSocial, "social");
        cleanStudyEl <- getEdgeList(edgelistStudy, "study")
        rvals = reactiveValues(nodes = cleanData, edgeK = cleanKnowEl, edgeSo = cleanSocialEl, edgeSt = cleanStudyEl);
        view(rvals$edgeSo)
        # Render three different network graphs and three different ego graphs (one for each tab)
        output$connectionGraph <- renderVisNetwork({
          visNetwork(rvals$nodes, rvals$edgeK, main = {paste("<p style=\"text-align: left;\"><font size=\"2\">Connection network graph for survey: <b>", surveyIdentity(), "</b></font>")}) %>%
            visEdges(arrows = "to") %>%
            visExport() %>%
            visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE);
        })
        
        output$socialGraph <- renderVisNetwork({
          visNetwork(rvals$nodes, rvals$edgeSo, main = {paste("<p style=\"text-align: left;\"><font size=\"2\">Social network graph for survey: <b>", surveyIdentity(), "</b></font>")}) %>%
            visEdges(arrows = "to") %>%
            visExport() %>%
            visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE);
        })
        
        output$studyGraph <- renderVisNetwork({
          visNetwork(rvals$nodes, rvals$edgeSt, main = {paste("<p style=\"text-align: left;\"><font size=\"2\">Study network graph for survey: <b>", surveyIdentity(), "</b></font>")}) %>%
            visEdges(arrows = "to") %>%
            visExport() %>%
            visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE);
        })
        
        output$connectionEgoGraph <- renderVisNetwork({
          #Check if node has been selected from connection graph if not don't render graph
          if(!is.null(input$connectionGraph_selected) && input$connectionGraph_selected != "") {
            nodeDataFrame = select(alterData, networkCanvasUUID, Name, networkCanvasEgoUUID, self);
            colnames(nodeDataFrame) <- c("id", "label", "EgoID", "IsEgo")
            
            egoidValue <- filter(nodeDataFrame, input$connectionGraph_selected == nodeDataFrame$id & nodeDataFrame$IsEgo == "true");
            nodeDataFrameFiltered <- filter(nodeDataFrame, egoidValue[1,3] == nodeDataFrame$EgoID);
            
            edgeListFrameFiltered <- filter(rvals$edgeK, egoidValue[1,3] == rvals$edgeK$EgoID);
            
            visNetwork(nodeDataFrameFiltered, edgeListFrameFiltered, main = {paste("Connection ego network graph for ", egoidValue[1,2])}) %>%
              visEdges(arrows = "to") %>%
              visExport() %>%
              visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE);
          }
        })
        output$studyEgoGraph <- renderVisNetwork({
          #Check if node has been selected from study graph if not don't render graph
          if(!is.null(input$studyGraph_selected) && input$studyGraph_selected != "") {
            nodeDataFrame = select(alterData, networkCanvasUUID, Name, networkCanvasEgoUUID, self);
            colnames(nodeDataFrame) <- c("id", "label", "EgoID", "IsEgo")
            
            egoidValue <- filter(nodeDataFrame, input$connectionGraph_selected == nodeDataFrame$id & nodeDataFrame$IsEgo == "true");
            nodeDataFrameFiltered <- filter(nodeDataFrame, egoidValue[1,3] == nodeDataFrame$EgoID);
            
            edgeListFrameFiltered <- filter(rvals$edgeSt, egoidValue[1,3] == rvals$edgeSt$EgoID);
            
            visNetwork(nodeDataFrameFiltered, edgeListFrameFiltered, main = {paste("Study ego network graph for ", egoidValue[1,2])}) %>%
              visEdges(arrows = "to") %>%
              visExport() %>%
              visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE);
          }
        })
        
        output$socialEgoGraph <- renderVisNetwork({
          #Check if node has been selected from social graph if not don't render graph
          if(!is.null(input$socialGraph_selected) && input$socialGraph_selected != "") {
            nodeDataFrame = select(alterData, networkCanvasUUID, Name, networkCanvasEgoUUID, self);
            colnames(nodeDataFrame) <- c("id", "label", "EgoID", "IsEgo")
            
            egoidValue <- filter(nodeDataFrame, input$connectionGraph_selected == nodeDataFrame$id & nodeDataFrame$IsEgo == "true");
            nodeDataFrameFiltered <- filter(nodeDataFrame, egoidValue[1,3] == nodeDataFrame$EgoID);
            
            edgeListFrameFiltered <- filter(rvals$edgeSo, egoidValue[1,3] == rvals$edgeSo$EgoID);
            
            visNetwork(nodeDataFrameFiltered, edgeListFrameFiltered, main = {paste("Social ego network graph for ", egoidValue[1,2])}) %>%
              visEdges(arrows = "to") %>%
              visExport() %>%
              visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE);
          }
        })
      })
      
      #By rendering UI here we can dynamically render ui parts if necessary if not will put back in UI portion
      output$Graph <- renderUI({
        ns <- session$ns
        tabsetPanel(
          id = ns("networkGraph"),
          tabPanel(
            "Connection",
            column(8,
                   visNetworkOutput(ns('connectionGraph')),
            ),
            column(4,
                   visNetworkOutput(ns('connectionEgoGraph'))
            )
          ),
          tabPanel(
            "Social",
            column(8,
                   visNetworkOutput(ns('socialGraph')),
            ),
            column(4,
                   visNetworkOutput(ns('socialEgoGraph'))
            )
          ),
          tabPanel(
            "Study",
            column(8,
                   visNetworkOutput(ns('studyGraph')),
            ),
            column(4,
                   visNetworkOutput(ns('studyEgoGraph'))
            )
          ),
        )
      })
      output$Settings <- renderUI({
        ns <- session$ns
        box(
          width = 12,
          status = "info",
          selectInput(
            ns("scaling"), 
            "Scale Metric",
            c("Course Score","Team Size","Grade"),
          ),
          selectInput(
            ns("coloring"), 
            "Node Color",
            c("Course Score","Team Size","Team","Class Section","Grade"),
          )
        )
      })
    }
  )
}
