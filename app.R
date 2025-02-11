# Packages
library(shiny)
library(bslib)
library(brpop)
library(vchartr)
library(dplyr)

# Read municipality seats data
mun_seats <- readRDS("data/mun_seats.rds")

# Municipality list for selector
mun_names <- mun_seats$code_muni
names(mun_names) <- paste(mun_seats$name_muni, "-", mun_seats$abbrev_state)

# Interface
ui <- page_navbar(
  title = "BR Pop", 
  theme = bs_theme(bootswatch = "shiny"),

  # Logo
  tags$head(
    tags$script(
      HTML('$(document).ready(function() {
             $(".navbar .container-fluid")
               .append("<img id = \'myImage\' src=\'selo_obs_h.png\' align=\'right\' height = \'57.5px\'>"  );
            });')),
    tags$style(
      HTML('@media (max-width:992px) { #myImage { position: fixed; right: 10%; top: 0.5%; }}')
    )),

  # Translation
  tags$script(
    HTML("
      $(document).ready(function() {
        // Change the text 'Expand' in all tooltips
        $('.card.bslib-card bslib-tooltip > div').each(function() {
          if ($(this).text().includes('Expand')) {
            $(this).text('Expandir');
          }
        });
  
        // Use MutationObserver to change the text 'Close'
        var observer = new MutationObserver(function(mutations) {
          $('.bslib-full-screen-exit').each(function() {
            if ($(this).html().includes('Close')) {
              $(this).html($(this).html().replace('Close', 'Fechar'));
            }
          });
        });
  
        // Observe all elements with the class 'card bslib-card'
        $('.card.bslib-card').each(function() {
          observer.observe(this, { 
            attributes: true, 
            attributeFilter: ['data-full-screen'] 
          });
        });
      });
    ")
  ),

  # Map page
  nav_panel(
    title = "População",

    # Sidebar
    layout_sidebar(
      sidebar = sidebar(
        # Select municipality
        selectizeInput(
          inputId = "mun", 
          label = "Município", 
          choices = NULL
        ),
        
        # Select sex
        selectizeInput(
          inputId = "sex", 
          label = "Sexo", 
          choices = c("Ambos", "Masculino", "Feminino")
        ),

        # Select age group
        selectizeInput(
          inputId = "age_group", 
          label = "Faixa etária", 
          choices = c("Todas")
        ),

        # Select population source
        selectizeInput(
          inputId = "pop_source", 
          label = "Estimativas populacionais", 
          choices = c("RIPSA/DEMAS","DataSUS", "UFRN", "IBGE/TCU"),
          multiple = TRUE,
          selected = c("RIPSA/DEMAS","DataSUS")
        ),
      ),

      # Card
      card(
        full_screen = TRUE,
        card_body(
          class = "p-0" # Fill card, used for maps
        )
      )

    )
  ),

  # Graphs page
  nav_panel(
    title = "Indicadores básicos",

    layout_sidebar(
      sidebar = sidebar(
        
      ),

      # Graphs card
      card(
        full_screen = TRUE,
        card_header("Card header"),
        card_body(
          
        )
      )
    )
  ),

  # About page
  nav_panel(
    title = "Dados e conceitos",
    card(
      card_header("Card title"),
      p("Bla bla bla.")
    ),
    accordion(
      multiple = FALSE,
      accordion_panel(
        "Título A",
        p("Bla bla bla.")
      ),
      accordion_panel(
        "Título B",
        p("Bla bla bla.")
      ),
      accordion_panel(
        "Título C",
        p("Bla bla bla.")
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  # Update municipality list
  observe(({
    updateSelectizeInput(
      session = session, 
      server = TRUE,
      inputId = "mun",
      choices = mun_names
    )
  }))

}

shinyApp(ui, server)