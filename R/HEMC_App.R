server_HEMC <- function(input, output,session) {
  
  # my functions
  
  Rsq <- function (model) 
  {
    if (!inherits(model, c("lm", "aov", "nls"))) 
      stop("'Rsq' is only applied to the classes: 'lm', 'aov' or 'nls'.")
    if (inherits(model, c("glm", "manova", "maov", 
                          "mlm"))) 
      stop("'Rsq' is not applied to an object of this class!")
    pred <- predict(model)
    n <- length(pred)
    res <- resid(model)
    w <- weights(model)
    if (is.null(w)) 
      w <- rep(1, n)
    rss <- sum(w * res^2)
    resp <- pred + res
    center <- weighted.mean(resp, w)
    if (inherits(model, c("lm", "aov"))) {
      r.df <- model$df.residual
      int.df <- attr(model$terms, "intercept")
      if (int.df) {
        mss <- sum(w * scale(pred, scale = FALSE)^2)
      }
      else {
        mss <- sum(w * scale(pred, center = FALSE, scale = FALSE)^2)
      }
      r.sq <- mss/(mss + rss)
      adj.r.sq <- 1 - (1 - r.sq) * (n - int.df)/r.df
      out <- list(R.squared = r.sq, adj.R.squared = adj.r.sq)
    }
    else {
      r.df <- summary(model)$df[2]
      int.df <- 1
      tss <- sum(w * (resp - center)^2)
      r.sq <- 1 - rss/tss
      adj.r.sq <- 1 - (1 - r.sq) * (n - int.df)/r.df
      out <- list(pseudo.R.squared = r.sq, adj.R.squared = adj.r.sq)
    }
    class(out) <- "Rsq"
    return(out)
  }
  
  
  
  
  # wrc
  HEMC <- function (x,thetaS,thetaR,alpha, n, b0,b1,b2) {
    
    out <- thetaR + ( (thetaS-thetaR)*(1 + (alpha*x)^n)^( (1/n) - 1) ) + (b2*x^2 + b1*x + b0)
    return(out)
    
  }
  

  
# INPUT DATA -------------------------------------------
  
  outdf <- NULL
  outdf <- reactive({ 
    req(input$infile)
    inFile <- input$infile
    df <- read.csv(inFile$datapath, header = TRUE, sep = input$sep2)
    return(df)
  })
  
  
  output$contents <- renderPrint({
    inFile <- input$infile
    RETOR <- matrix(nrow=1,ncol=1,data=c("Awaiting input data!"));rownames(RETOR) <- "";colnames(RETOR) <- ""
    if (!is.null(inFile)) {RETOR <- outdf()}
    RETOR
  })
  
  
  

  
  
  
  
# CURVE ------------------------------
  
  outdf1 <- NULL
  outdf1 <- reactive({ 
    req(input$infile)
    inFile <- input$infile
    df <- read.csv(inFile$datapath, header = TRUE, sep = input$sep2)
    
    updateSelectInput(session, inputId = 'xcol', 
                      choices = names(df), selected = names(df))
    updateSelectInput(session, inputId = 'ycol', 
                      choices = names(df), selected = names(df))
    return(df)
  })
  
  
  output$contents1 <- renderPrint({
    
    inFile <- input$infile
    RETOR <- matrix(nrow=1,ncol=1,data=c("Awaiting input data!"));rownames(RETOR) <- "";colnames(RETOR) <- ""
    if (!is.null(inFile)) {RETOR <- outdf1()}
    RETOR

  })
  
  
  
  output$plot <- renderPlot({
    
    
    par(cex=0.9)
    plot(x=1,y=1,xlab="",
         xlim=c(1,input$xlim),yaxt='n',xaxt='n',
         ylab="", ylim=c(0,input$ylim), type="l", lwd=2)
    mtext(expression(theta~(m^3~m^-3)), 2, line=2.3)
    mtext("h (hPa)", 1, line=2.3)
    axis(1)
    axis(2)
    
    
    if (input$m==FALSE) {
      mtext(expression(  theta(h)==theta[r]~"+"~"["~(theta[s]-theta[r])/(1+~(alpha*h)^n)^{(1-1/n)}~"]" + b[2]^h + b[1]*h + b[0]   ),
            3,line=2, cex=0.9)
      
    }
    
    if (input$exp==FALSE) {
      if (input$xcol!= "" & input$ycol!= "") {
        points(x=outdf1()[,input$xcol],y=outdf1()[,input$ycol],pch=15)
      }
    }
    
    if (input$red==FALSE) {
      h <- seq(1,input$xlim, len=100)
      w <- HEMC(x=h,
                thetaS=input$thetaS,
                thetaR=input$thetaR,
                alpha=input$alpha, n=input$n,
                b0=input$b0,b1=input$b1,b2=input$b2)
      points(x=h, y=w, type="l", col="red")
    }
    
    

    
    
    OUT <- mySUMMARY$fitting
    if (class(OUT[[1]])=="summary.nls") {
      
      data <- OUT[[1]]$parameters[,1]
      names <- rownames(OUT[[1]]$parameters)
      table <- matrix(nrow=2,ncol=length(data))
      table <- as.data.frame(table)
      colnames(table) <- names
      table[1,] <- data
      

      if (length(table[1,])==6){
        thetaR <- table$thetaR[1]
        alpha <- table$alpha[1]
        n <- table$n[1]
        b0 <- table$b0[1]
        b1 <- table$b1[1]
        b2 <- table$b2[1]
      }
      
      if (length(table[1,])!=6){
        
        thetaR <- min(sort(outdf1()[,input$ycol])) # medido
        alpha <- table$alpha[1]
        n <- table$n[1]
        b0 <- table$b0[1]
        b1 <- table$b1[1]
        b2 <- table$b2[1]
        
      }
      
      if (input$blue==FALSE) {
      hexp <- seq(from=min(sort(outdf1()[,input$xcol])),to=max(sort(outdf1()[,input$xcol])), len=100)
      w <- HEMC(x=hexp,
                thetaS=max(sort(outdf1()[,input$ycol])), # medido
                thetaR=thetaR,
                alpha=alpha,n=n,
                b0=b0,b1=b1,b2=b2)
      points(x=hexp, y=w, type="l", col="blue")
      legend("topright",legend="Fitted model", lwd=1, col="blue")
      }
      
      data.out <- reactive({
        
        dataDOWN <- data.frame(h=hexp,w=w)
        dataDOWN
        
      })
      
      output$download <- downloadHandler(
        filename = function(){"curve.csv"}, 
        content = function(fname){
              write.csv(data.out(), fname,row.names = FALSE)
        }
      )
      
      
    }
    
    
  })
  
  
  
  
  
  mySUMMARY <- reactiveValues(Data=NULL)
  mySTAT<- reactiveValues(Data=NULL)
  
  observeEvent(input$start,{
    
    OUT <- NULL
    x <- outdf1()[,input$xcol]
    w <- outdf1()[,input$ycol]
    
    thetaS <- max(sort(w))  # medido
    thetaR <- min(sort(w))  # medido
    alpha <- input$alpha
    n <- input$n
    b0 <- input$b0
    b1 <- input$b1
    b2 <- input$b2
    
    lista <- list()
    if (input$thetaSR==FALSE) {lista <- c(thetaR=input$thetaR,alpha=alpha,n=n,b0=b0,b1=b1,b2=b2)}
    if (input$thetaSR==TRUE) {lista <- c(alpha=alpha,n=n,b0=b0,b1=b1,b2=b2)}
    
    m <- try(nls(w ~ thetaR + ( (thetaS-thetaR)*(1 + (alpha*x)^n)^( (1/n) - 1) ) + (b2*x^2 + b1*x + b0) , start=lista))
    if (class(m)=="try-error") {OUT <- OUT}
    OUT <- list(summary(m), m)
    mySUMMARY$fitting <- OUT
    
    
    if (class(m)=="nls") {
      STAT <- NULL
      res = residuals(m)
      MAPE = 100 * mean(abs(res)/(res + predict(m)))
      STAT <- format(data.frame("R2"=Rsq(m)$pseudo, AIC=AIC(m),MAPE), digits = 4)
      rownames(STAT) <- ""
      mySTAT$stat <- STAT
    }
    
    
  })
  
  
  output$fitting <- renderPrint({
    
    OUT <- NULL
    if (!is.null(mySUMMARY$fitting[[1]]) || class(mySUMMARY$fitting[[1]])!="summary.nls") {OUT <- matrix(nrow=1,ncol=1,data=c("Try again!"));rownames(OUT) <- "";colnames(OUT) <- ""}
    if (class(mySUMMARY$fitting[[1]])=="summary.nls") {OUT <- mySUMMARY$fitting[[1]]$parameters[,-3]}
    if (is.null(mySUMMARY$fitting[[1]])) {OUT <- matrix(nrow=1,ncol=1,data=c("Moves the slider input for a numerical starting"));rownames(OUT) <- "";colnames(OUT) <- ""}
    OUT
    
  })
  
  
  output$stat <- renderPrint({
    
    STAT <- NULL
    if (!is.null(mySUMMARY$fitting[[1]]) || class(mySUMMARY$fitting[[1]])!="summary.nls") {STAT <- NULL}
    if (class(mySUMMARY$fitting[[1]])=="summary.nls") {STAT <- mySTAT$stat}
    if (is.null(mySUMMARY$fitting[[1]])) {STAT <- NULL}
    STAT
    
  })
  
  
 # end  
 
}






ui_HEMC <- fluidPage(
  
  
  tags$style(type = 'text/css', 
             '.navbar { background-color: LightSkyBlue;}',
             '.navbar-default .navbar-brand{color: black;}',
             '.tab-panel{ background-color: black; color: black}',
             '.nav navbar-nav li.active:hover a, .nav navbar-nav li.active a {
                        background-color: black ;
                        border-color: black;
                        }'
             
  ),
  


  navbarPage(
    
 "HEMC",
 


           
           
           
           tabPanel("Input file field",h4("INPUT FILE FIELD"),
                    
                    
                    
                
                      column(4,wellPanel(
                        fluidRow(
                          
                          column(6,
                                 fileInput('infile', 'Choose data (.csv or .txt)',
                                           accept=c('text/csv', 
                                                    'text/comma-separated-values,text/plain', 
                                                    '.csv')),
                             
                                 actionLink(inputId='ab1', label="File example (.csv)", 
                                              icon = icon("th"), 
                                              onclick ="window.open('https://ce99d4d6-d4c5-48a3-b911-9e83247054ca.filesusr.com/ugd/45a659_63f52554da2047199bbf09b5db6a0c20.csv?dn=HEMC_data.csv', '_blank')")

                                 
                          ),
                          
                          column(6,
                                 radioButtons('sep2', 'File separator',
                                              c(Comma=',',
                                                Semicolon=';',
                                                Tab='\t'),
                                              ',')),
                          column(12,
                                 actionLink(inputId='ab1', label="File example (.txt)", 
                                            icon = icon("th"), 
                                            onclick ="window.open('https://ce99d4d6-d4c5-48a3-b911-9e83247054ca.filesusr.com/ugd/45a659_414774e0b8bb4467b1a59d931d89f09d.txt?dn=HEMC_data.txt', '_blank')"))
                          
                          
                          
                          ))),

                    
                  
                      column(8,wellPanel(h4(tags$p("DATA",style = "font-size: 80%;text-align:justify")),
                                         fluidRow(
                                           
                                           verbatimTextOutput('contents')
                                           
                                           
                                         )))
                      
                      
                      
                      
          ),
                    
           


# Pierson and Mulla (1989)

tabPanel("Pierson and Mulla (1989)",h4("Pierson and Mulla"),
         
         
         verticalLayout(
           column(12,wellPanel(
             
             helpText(tags$p("Fit ",tags$strong("Pierson & Mulla's")," High Energy Moisture Characteristic (HEMC) curve for measuring aggregate stability. 
                                        Input your data pairs in the ",tags$strong("INPUT FILE FIELD")," and then move the sliders to find a suitable set of starting parameters. 
                                        Get the red line as close of the points as possible. Then, try clicking on ",tags$strong("Estimate")," to obtain the best (least square) 
                                        fitting. If the model did not achieve convergence, you should try again with another set of starting parameters",
                             
                             style = "font-size: 95%;text-align:justify"))
             
           ))),
         
         

        
         column(3,wellPanel(h4(tags$p("DATA",style = "font-size: 80%;text-align:justify")),
                            fluidRow(
                              column(6,
                                     selectInput('xcol', 'h', "", selected = "")),
                              column(6,
                                     selectInput('ycol', HTML(paste0("&theta;")), "", selected = "")),
                              verbatimTextOutput('contents1')
                              
                              
                            ))),

         
         
         column(2,wellPanel(h4(tags$p("Starting parameters",style = "font-size: 85%;text-align:justify")),
                            
                            
                            sliderInput("thetaS", HTML(paste0("&theta;",tags$sub("s") ," (m",tags$sup("3") ," m",tags$sup("-3"),")")),
                                        min = 0, max = 0.80,
                                        step = 0.001, value=0.73,tick=FALSE),
    
                            sliderInput("thetaR", HTML(paste0("&theta;",tags$sub("r") ," (m",tags$sup("3") ," m",tags$sup("-3"),")")),
                                        min = 0, max = 0.40,
                                        step = 0.01, value=0.35,tick=FALSE),
     
                            sliderInput("alpha", HTML(paste0("&alpha;",tags$sub("")," (hPa",tags$sup("-1"),")")),
                                        min = 0, max = 0.5,
                                        step = 0.001, value=0.1,tick=FALSE),
                            
                            sliderInput("n", HTML(paste0("n",tags$sub(""),"")),
                                        min = 1, max = 20,
                                        step = 0.001,value = 10,tick=FALSE),
                            
                            
                            sliderInput("b0", HTML(paste0("b",tags$sub("0"))),
                                        min = -1, max = 1,
                                        step = 0.001, value=0.02,tick=FALSE),
                            
                            sliderInput("b1", HTML(paste0("b",tags$sub("1"),"")),
                                        min = -1, max = 0.02,
                                        step = 0.00001, value=-0.0057,tick=FALSE),
                            
                            sliderInput("b2", HTML(paste0("b",tags$sub("2"),"")),
                                        min = -1, max = 1,
                                        step = 0.000001,value = 0.00004,tick=FALSE),
                            
                            br(),
                            
                            checkboxInput("thetaSR", "", value = FALSE),
                            
                            helpText(
                              HTML(paste0("Check this box to consider ","&theta;",tags$sub("s")," and ","&theta;",tags$sub("r"),
                                          " from the experimental data (the algorithm will take the minimum and maximum values of water content)")),
                              style = "font-size: 90%;text-align:justify"))
                
                
                
                
                
                
         ),
         
         
         
         column(4,wellPanel(
           h4("Water retention curve"),
           plotOutput("plot"),
           
           helpText(
             HTML(paste0("WARNING! To facilitate the fitting, the algorithm considers ","&theta;",tags$sub("s")," from the measured data (maximum water content value).")),
             HTML("A blue line will appear when the model has been successfully fitted"),
             style = "font-size: 93%;text-align:justify"),
           fluidRow(
             column(6,
                  sliderInput("ylim", HTML(paste0("&theta;",tags$sub("lim"))),
                              min = 0, max = 1,
                              step = 0.01, value=0.8,tick=FALSE),
             sliderInput("xlim", HTML(paste0("h",tags$sub("lim"))),
                         min = 0, max = 100,
                         step = 1, value=40,tick=FALSE)),
             
             column(6,
           checkboxInput("red","Remove red line", FALSE),
           checkboxInput("blue","Remove blue line", FALSE),
           checkboxInput("exp","Remove data", FALSE),
           checkboxInput("m","Remove equation", FALSE)))
           
           
         )         
         ),
         
         
         
         column(3,wellPanel(
           
           actionButton(inputId = "start",label = "Estimate",class = "btn btn-primary"),
           br(),
           br(),
           verbatimTextOutput("fitting"),
           verbatimTextOutput("stat"),
           helpText(
             HTML(paste0("R",tags$sup("2"),": coefficient of determination;")),
             HTML("AIC: Akaike Information Criterion;"),
             HTML("MAPE: mean absolute percentage error"),
             style = "font-size: 70%;text-align:justify"),
             br(),
           downloadButton("download", "Download fitted data",class = "btn btn-primary")
           
         )),
         
         
         
         verticalLayout(
           column(12,wellPanel(
             h4("Useful links"),
             
             actionButton(inputId='ab1', label="Pierson and Mulla (1989)", 
                          icon = icon("th"), 
                          onclick ="window.open('https://acsess.onlinelibrary.wiley.com/doi/abs/10.2136/sssaj1989.03615995005300060035x', '_blank')"),
             
             actionButton(inputId='ab1', label="Carneiro (2016)", 
                          icon = icon("th"), 
                          onclick ="window.open('https://www.teses.usp.br/teses/disponiveis/11/11140/tde-28092016-155747/pt-br.php', '_blank')"),
             
            
             actionButton(inputId='ab1', label="Pressure unit converter", 
                          icon = icon("th"), 
                          onclick ="window.open('http://www.unitconversion.org/unit_converter/pressure.html', '_blank')")
             
             
           )))),




tabPanel("About", "",
         
         
         verticalLayout(
           column(12,wellPanel(
             
             tags$p("This R app is an interactive web interface for fitting the High Energy Moisture Characteristic (HEMC) curve for measuring aggregate stability
             and integrate the set of functions for soil physical data 
                    analysis from the R package ",tags$em(tags$strong('soilphysics')),"", 
                    style = "font-size: 115%;text-align:justify"),
             
             
             actionButton(inputId='ab1', label="soilphysics", 
                          icon = icon("th"), 
                          onclick ="window.open('https://arsilva87.github.io/soilphysics/')")
             
           ))),
         
         verticalLayout(
           column(12,wellPanel(
             tags$p("Developed by: Renato P. de Lima & Anderson R. da Silva", style = "font-size: 90%;")))),
         
         
         verticalLayout(
           column(12,wellPanel(
             tags$p("Suggestions and bug reports: renato_agro_@hotmail.com; anderson.silva@ifgoiano.edu.br", style = "font-size: 90%;")
             
             
             
             
           ))))

)



)


HEMC_App <- function() {
  shinyApp(ui_HEMC , server_HEMC)
  }






