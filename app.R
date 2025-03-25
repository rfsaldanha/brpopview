# Packages
library(shiny)
library(bslib)
library(vchartr)
library(dplyr)

# Read municipality seats data
mun_seats <- readRDS("data/mun_seats.rds")

# Municipality list for selector
mun_names <- mun_seats$code_muni
names(mun_names) <- paste(mun_seats$name_muni, "-", mun_seats$abbrev_state)

# Population base data
# pop_datasus <- brpop::mun_pop_totals(source = "datasus") |>
#   mutate(source = "DataSUS")
# pop_datasus2024 <- brpop::mun_pop_totals(source = "datasus2024") |>
#   mutate(source = "RIPSA/DEMAS")
# pop_ufrn <- brpop::mun_pop_totals(source = "ufrn") |>
#   mutate(source = "UFRN")
# pop_ibge <- brpop::mun_pop_totals(source = "ibge") |>
#   mutate(source = "IBGE/TCU")
# pop <- bind_rows(pop_datasus, pop_datasus2024, pop_ufrn, pop_ibge) |>
#   mutate(code_muni = substr(code_muni, 0, 6))
# rm(pop_datasus, pop_datasus2024, pop_ufrn)
# saveRDS(pop, file = "data/pop.rds")
pop <- readRDS(file = "data/pop.rds")

# Interface
ui <- page_navbar(
  title = "Estimativas populacionais no Brasil",
  theme = bs_theme(bootswatch = "cosmo"),

  # Logo
  tags$head(
    tags$script(
      HTML(
        '$(document).ready(function() {
             $(".navbar .container-fluid")
               .append("<img id = \'myImage\' src=\'logo_icict_150.png\' align=\'right\' height = \'57.5px\'>"  );
            });'
      )
    ),
    tags$style(
      HTML(
        '@media (max-width:992px) { #myImage { position: fixed; right: 10%; top: 0.5%; }}'
      )
    )
  ),

  # Translation
  tags$script(
    HTML(
      "
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
    "
    )
  ),

  # Map page
  nav_panel(
    title = "Gráfico",

    # Sidebar
    layout_sidebar(
      sidebar = sidebar(
        # Select municipality
        selectizeInput(
          inputId = "mun",
          label = "Município",
          choices = NULL
        ),

        # Select population source
        selectizeInput(
          inputId = "pop_source",
          label = "Estimativas populacionais",
          choices = c("RIPSA/DEMAS", "DataSUS", "UFRN", "IBGE/TCU"),
          multiple = TRUE,
          selected = c("RIPSA/DEMAS", "DataSUS", "UFRN")
        ),
      ),

      # Card
      card(
        full_screen = TRUE,
        card_body(
          class = "p-0",
          vchartOutput(outputId = "graph_pop")
        )
      )
    )
  ),

  # About page
  nav_panel(
    title = "Fontes dos dados",
    p(
      "Os dados foram extraídos do pacote {brpop}, conforme detalhado a seguir."
    ),
    accordion(
      multiple = FALSE,
      accordion_panel(
        "RIPSA/DEMAS",
        p(
          "Estimativas populacionais municipaisde 2000 a 2024 por sexo e idade, calculadas pelo Ministério da Saúde/DEMAS para o uso em indicadores de saúde."
        )
      ),
      accordion_panel(
        "DataSUS",
        p(
          "Estimativas populacionais municipais de 2000 a 2022, por sexo e idade."
        )
      ),
      accordion_panel(
        "UFRN",
        p(
          "Estimativas populacionais municipais de 2010 a 2030, por sexo e idade, calculadas pelo Departamento de Demografia da UFRN."
        )
      ),
      accordion_panel(
        "IBGE/TCU",
        p(
          "Estimativas populacionais municipais anuais enviadas pelo IBGE para o Tribunal de Contas da União (TCU)."
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  # Update municipality list
  observe(
    ({
      updateSelectizeInput(
        session = session,
        server = TRUE,
        inputId = "mun",
        choices = mun_names,
        selected = "330455"
      )
    })
  )

  # Render population graph
  output$graph_pop <- renderVchart({
    req(input$mun)
    req(input$pop_source)

    pop |>
      filter(code_muni == substr(input$mun, 0, 6)) |>
      filter(source %in% input$pop_source) |>
      arrange(year) |>
      vchart() |>
      v_line(
        aes(x = year, y = pop, color = source),
        line = list(style = list(lineWidth = 3)),
        point = list(visible = TRUE),
      ) |>
      v_mark_vline(x = "2000") |>
      v_mark_vline(x = "2010") |>
      v_mark_vline(x = "2022") |>
      v_scale_y_continuous(
        labels = format_num_d3(
          format = ",.0f",
          locale = "pt-BR"
        )
      ) |>
      v_labs(
        title = "Estimativas populacionais",
        x = "Ano",
        y = "Estimativa populacional"
      ) |>
      v_specs_legend(
        orient = "right",
        position = "middle",
        item = list(focus = TRUE)
      )
  })
}

shinyApp(ui, server)
