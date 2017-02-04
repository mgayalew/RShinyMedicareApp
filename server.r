library(shiny)
library(ggvis)
library(dplyr)
if (FALSE) library(RSQLite)
library(stargazer)


# Set up handles to database tables on app start
mdClm <- read.csv(paste("./data/Medicare Hospital Spending by Claim.csv", sep=""))
mdClm <- arrange(mdClm, State, Hospital_Name)			
mdClm$ID <- seq(1,length(mdClm$Hospital_Name),1)
mdClm$prvdrSpndng <-  paste(paste0(mdClm$Hospital_Name,": "), paste0("$", format(mdClm$Avg_Spending_Per_Episode_Hospital, big.mark = ",", scientific = FALSE),";"))
mdClm <-  mdClm %>%
			filter(Period != "Complete Episode" & Claim_Type != "Total")
mdClm <- rename(mdClm, AvgSpndngHsptl=Avg_Spending_Per_Episode_Hospital, AvgSpndngState=Avg_Spending_Per_Episode_State, AvgSpndngNtn=Avg_Spending_Per_Episode_Nation) 

					
function(input, output, session) {

  mdClmFnl <- reactive({
    # Apply filters
	mdClm %>%
		filter(State == input$state, Period == input$period, Claim_Type == input$clmType) 
  })

  
  
  # Function for generating tooltip text
  mdclm_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$ID)) return(NULL)

    # Pick out the average spending with this ID
    all_mdClmFnl <- isolate(mdClmFnl())
    mdClms <- all_mdClmFnl[all_mdClmFnl$ID == x$ID, ]

    paste0("<b>", "State: ", mdClms$State, "</b><br>",
			"Provider Name: ", mdClms$Hospital_Name, "<br>",
			"Spending: ", "$", format(mdClms$AvgSpndngHsptl, big.mark = ",", scientific = FALSE)
    )
  }

  # A reactive expression with the ggvis plot
  vis <- reactive({
	mdClmFnl() %>%
		ggvis(x = ~ID , y = ~AvgSpndngHsptl) %>%
		layer_points(size := 100, size.hover := 300, 
					fillOpacity := 0.1, fillOpacity.hover := 0.5, stroke.hover := "red", fill.hover :="red",
					stroke = ~AvgSpndngHsptl, key := ~ID) %>%
		add_tooltip(mdclm_tooltip, on = c("hover")) %>%
		add_axis("x", title = "Provider", properties = axis_props(title = list(fontSize = 16))) %>%
		add_axis("y", title = "Medicare Hospital Spending by Claim", title_offset=50,
					properties = axis_props(title = list(fontSize = 16))) %>%
		add_legend("stroke", title = "Average Spending") %>%
		set_options(width = 1000, height = 500)
	})

  vis %>% bind_shiny("sctrPlot")

  output$nmbrProviders <- renderText({ length(unique(mdClmFnl()$Hospital_Name)) })

  # Summary statistics 
  output$smryTable <- renderPrint({
    AvgSpndngpEH <- data.frame(AvgSpndngpEH=mdClmFnl()$AvgSpndngHsptl)
	if(nrow(AvgSpndngpEH) > 0){
		stargazer(AvgSpndngpEH , type = "text", title="Summary of Medicare Average Spending per Episode Hospital", digits=0, median=TRUE, iqr=TRUE, min.max=TRUE)
	} else {
	print(paste("No Observation"))
	}
  })
  

  mdClmFnl <- reactive({
    # Apply filters
	mdClm %>%
		filter(State == input$state, Period == input$period, Claim_Type == input$clmType) 
  })
  
  
  
  OrdrdBySpndng <- reactive({
    # Apply filters
	mdClm %>%
		arrange(desc(AvgSpndngHsptl)) %>%
		filter(State == input$state, Period == input$period, Claim_Type == input$clmType)  
	})

	output$topProviders <- renderText({head(OrdrdBySpndng()$prvdrSpndng, n=10) })
}





