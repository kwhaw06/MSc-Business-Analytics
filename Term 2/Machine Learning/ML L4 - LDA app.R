library(shiny)
library(shinythemes)
ui <- fluidPage(theme = shinytheme("lumen"),
                titlePanel("Projection of iris data"),
                sidebarLayout(
                  sidebarPanel(
                    # Select type of projection to plot
                    selectInput(inputId = "type", label = strong("Projection type"),
                                choices = c("PCA","LDA"),
                                selected = "PCA")
                  ),
                  # Output: Description, lineplot, and reference
                  mainPanel(
                    plotOutput(outputId = "projection")
                  )
                )
)

# Define server logic required to draw a projection plot ----
server <- function(input, output) {
  output$projection <- renderPlot({
    data(iris)
    if(input$type=="LDA"){
      library(MASS)
      fit=lda(Species~.,data=iris)
      iris_proj=as.matrix(iris[,-5])%*%(fit$scaling)
    }else{
      pr.out = prcomp(iris[,-5], scale = TRUE)
      iris_proj=pr.out$x[,1:2]
    }
    cols<- c("steelblue1", "hotpink", "mediumpurple")  
    pchs<-c(1,2,3)
    ########## projection plot
    plot(iris_proj[1:50,1],iris_proj[1:50,2],pch=1,
         xlim=c(-12,10),xlab=" ",ylab=" ",
         cex.lab=1.5, cex=1.5,
         cex.axis=1.5,  font.lab=2,col="steelblue1")
    if(input$type=="LDA"){
      title(xlab="LD1",ylab="LD2")
    }else{
      title(xlab="PC1",ylab="PC2")
    }
    points(iris_proj[51:100,1],iris_proj[51:100,2],pch=2,col="hotpink")
    points(iris_proj[101:150,1],iris_proj[101:150,2],pch=3,col="mediumpurple")
    legend("bottomright",legend=c("setosa","versicolor","virginica"),
           col=cols,pch=pchs,cex=1,text.font=2)
  })
}
shinyApp(ui = ui, server = server)