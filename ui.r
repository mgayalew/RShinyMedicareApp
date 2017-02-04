#===========================================================================================;
# 	Author: Muluemebet G Ayalew	;
#	Date: Janury 10, 2017		;
#	Purpose: Develop R-Shiny apps to explore medicare spending differences across providers ;
#===========================================================================================;

library(ggvis)

fluidPage(
  #titlePanel("Medicare Hospital Spending by Claim"),
  h3("Exploring Average Medicare Hospital Spending by Period and Claim Type"),
  h4("Data Description"),
  p("Medical spending per beneficiary data and data description was obtained from", a("Data.Medicare.gov", href="https://data.medicare.gov/"),". The data displayed here shows average spending levels during hospitals’ Medicare Spending per Beneficiary (MSPB) episodes. An MSPB episode includes all Medicare Part A and Part B claims paid during the period from 3 days prior to a hospital admission through 30 days after discharge. These average Medicare payment amounts have been price-standardized to remove the effect of geographic payment differences and add-on payments for indirect medical education (IME) and disproportionate share hospitals (DSH)."),
  h4("Purpose of the Apps"),
  p("The aim of this shiny apps is to explore the differences on average spending across providers by period and claim type within states. The average spending was compared across states in", a("another blog", href="http://datascienceandme.com/topics/medicareAcrossStates.html")),
  p("The following scatter plot helps to visualize Medicare average spending per episode among different providers. You can explore average spending within each state for a given period and type of claim by selecting the state from the drop-down box, and period and claim type from the radio buttons. Summary statistics of average spending for a given selection is provided on the top of the application, followed by scatter plot of average spending. Provider with highest average spending are listed under the scatter plot. You can see the name of provider and the average spending by hovering the cursor on each observation. In summary the top ten highest average spending was for inpatient claims during index hospital admission in the state of Texas (3 providers), Ohio, Nebraska, Indiana, Kansas (each 1 provider) and Oklahoma (2 provider)."),
p("Note that if a given period and type of claim for a given state have no data, no observation appears on the scatter plot. "),
  fluidRow(
    column(3,
      wellPanel(
		selectInput("state", "USA States:", c("AK","AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY")),
		radioButtons("period", "Period: ", c("During Index Hospital Admission", "30 days After Discharge from Index Hospital Admission", "1 to 3 days Prior to Index Hospital Admission")),
		radioButtons("clmType", "Claim Type: ", c("Inpatient", "Skilled Nursing Facility", "Durable Medical Equipment Carrier", "Home Health Agency", "Hospice", "Outpatient"))
      )
    ),	
    column(9,
      verbatimTextOutput("smryTable"),
      ggvisOutput("sctrPlot"),
      wellPanel(
        span(h4("Total number of Providers:"),  textOutput("nmbrProviders") ),
        span(h4("Top 10 Providers with highest average spending in decreasing order:"),  textOutput("topProviders") )
	  )	
	)
  )
)