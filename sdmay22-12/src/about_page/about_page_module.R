#########
# Author: sdmay22-12 Team
#
# About Page Module: Contains helpful information pertaining to the application
# and its uses
#########

AboutPageUI <- function() {
  fluidPage(
    
    titlePanel(
      h1("About Page", align="center")
    ),
    
    fluidRow(
      box(
        title = "Network Graphs", 
        width = 6, 
        solidHeader = TRUE, 
        status = "danger",
        collapsible = TRUE,
        p("Network Graphs illustrate different types of connections among students in your course. You may choose the type of connection you would like to see (e.g. friendship, study partners) using the drop down menu."),
        p("The full network graph can help you identify things like:"),
        tags$div(
          tags$ul(
            tags$li("Emergent study groups in your course"),
            tags$li("The extent to which students are connected or disconnected"),
            tags$li("Isolated students who may be at risk"),
            tags$li("Whether students are sorting themselves into groups in ways that exclude other students (like transfer students, non-majors, on the basis of social identities)")
          )
        ),
        p("Cohesive classrooms with highly interconnected networks allow students to share information as well as provide emotional and academic support."),
        p("If your classroom looks highly segregated or if students in your class report few connections, consider employing active learning strategies like Peer Coding or collaborative problem solving."),
        p("If students are segregating themselves, require students to move around the room at the start of an activity or randomly sort students into groups to encourage more diverse connections."),
        p("You can always contact ", tags$a(href="mailto:rsmith2@iastate.edu", "Rachel "), "or ", tags$a(href="mailto:brownm@iastate.edu", "Michael "), "for assistance with instructional strategy development.")
      ),
      box(
        title = "Ego Graphs", 
        width = 6, 
        solidHeader = TRUE, 
        status = "danger",
        collapsible = TRUE,
        p("Ego-centric graphs allow you to illustrate the networks of individual students. While network graphs give you an overview of the classroom, ego-centric graphs allow you to focus on individuals."),
        p("For example, you might be interested in observing if students who frequently miss class are also socially or academically isolated. Or are students who regularly lose points on homework assignments working with study groups?"),
        p("By identifying what students are doing that might be related to real or potential academic difficulties, you can adapt the feedback you provide and the strategies you highlight. Ego-centric graphs can also be used during office hours to provide a snapshot of how a student who is seeking help is positioned in the classroom social network. It may not be effective, for example, to suggest to a student that they find an in-class study group when they have no social connections in the course.")
      )
    ),
    fluidRow(
      tabBox(
        title = "More helpful resources", 
        #lets us use input$aboutTabs on server to find current tab
        id = "aboutTabs",
        #Moves the tabs to the right of the title but reverses the order of the tabs
        #Therefore, reverse the order of the info in the code
        side = "right",
        width = NULL,
        height = NULL,
        selected = "Network Terminology",
        tabPanel("Using Dashboards for Course Feedback", 
                 p("In addition to the network graphs, you can visualize different forms of Learning Management system data to better understand what is working (and what might need to change) in your classroom."),
                 p("Behavioral data, like attendance, gains real efficacy when it is considered in concert with a visualization of classroom social networks."),
                 p("It is more useful, for example, to know that students who frequently miss class are also socially isolated in the classroom."),
                 p(strong("Use the dashboard to:")),
                 tags$div(
                   tags$ul(
                     tags$li("Look for patterns in how students are organizing themselves in your classroom"),
                     tags$li("Identify potential explanations for why students are academically struggling (socially or academically isolated, connected to other peers who are struggling, frequently miss class)"),
                     tags$li("Develop strategies for changing how you provide instruction during the term and in the future; for how and when students get feedback about how they are doing in the class; and for how you provide students opportunities to connect in your classroom.")
                   )
                 )
                 ),
        tabPanel("Get Students Interacting", 
                 p("There are a number of useful resources that can help you identify strategies that encourage connection and interaction among students. You might consider:"), 
            
                 p(strong("Peer Instruction:")),
                 "Crouch, C. H., & Mazur, E. (2001). Peer instruction: Ten years of experience and results.",
                 br(),
                 em("American journal of physics"), ", 69(9), 970-977",
                 tags$a(href="https://doi.org/10.1119/1.1374249", "https://doi.org/10.1119/1.1374249"),
                 
                 p(),
                 
                 p(strong("Project Based Learning:")),
                 "Blumenfeld, P. C., Soloway, E., Marx, R. W., Krajcik, J. S., Guzdial, M., & Palincsar, A. (1991). Motivating project-based learning: Sustaining the doing, supporting the learning.", em("Educational psychologist"), ", 26(3-4), 369-398.", 
                 br(),
                 tags$a(href="https://doi.org/10.1080/00461520.1991.9653139", "https://doi.org/10.1080/00461520.1991.9653139"),
                 
                 p(),
                 
                 p(strong("Active Learning for Addressing Educational Debts:")),
                 "How Active Learning Can Improve Inequities in STEM.", em("How Active Learning Can Improve Inequities in STEM | Teaching + Learning Lab"), ", MIT Teaching and Learning Lab,",
                 br(),
                 tags$a(href="https://tll.mit.edu/how-active-learning-can-improve-inequities-in-stem/.", "https://tll.mit.edu/how-active-learning-can-improve-inequities-in-stem/.")
                 ),
        tabPanel("Network Terminology",
          p(strong("Actor: "), "The discrete social entity. In our case, the actors are students."),
          p(strong("Node: "), "The actor is usually in a network graph as a shape, called a node. In our case, nodes are students."),
          p(strong("Tie: "), "The connection between any two nodes or actors, usually represented in a network graph as a type of line. In our case, ties are the lines between students who report some kind of relationship."),
          p(strong("Network: "), "A network is a collection of nodes and the ties between them. In our case, the network might be the students in a class or the members of a team."),
          p(strong("Ego: "), "An ego is a focal social entity. In our case, the ego would be the selected student that a graph is built around."),
          p(strong("Alter: "), "An alter is the person the ego is connected to."),
          p(strong("Ego network: "), "An ego network is all of the alters connected to an ego, and the ties between them."),
          p(strong("Sociometric network: "), "A sociometric network is made up of all the actors in a bounded community and the ties among them. In our case, the sociometric network would consist of all the students in the course."),
          p(strong("Tie Characteristics:")),
          tags$div(
            tags$ul(
              tags$li(strong("Direction: "), "Indicates which actor reported the tie. Direction can be indicated by a tie with an arrow."),
              tags$li(strong("Reciprocality: "), "A reciprocal tie is one that both actors report."),
              tags$li(strong("Content: "), "The type of relationship. In our case, content could include studying together or being friends."),
              tags$li(strong("Value: "), "A numeric quality attached to a tie. Tie strength can be measured in a variety of ways, usually through aspects like frequency or longevity.")
            )
          ),
          p(strong("Multiplex tie: "), "A multiplex tie is one with more than one type of content. In our case, students might have a relationship with someone who is both a friend and a study partner."),
          p(strong("Measures:")),
          tags$div(
            tags$ul(
              tags$li(strong("Degree: "), "a count of the number of alters an ego is connected to."),
              tags$li(strong("Density: "), "the number of potential ties in a network that actually exist (e.g. the number of reported ties divided by the maximum possible number of ties). A density of 1.0 is when everyone is connected to everyone else."),
              tags$li(strong("Centrality: "), "A measure of how connected an actor is within the network. There are different types of centrality and ways of measuring it (e.g. degree centrality, betweenness centrality, eigenvector centrality).")
            )
          )
        )
      )
    )
  )
}

