library(crosstalk)
library(plotly)

shared_mtcars <- SharedData$new(mtcars)
bscols(widths = c(3, NA),
       list(
         filter_checkbox("cyl", "Cylinders", shared_mtcars, ~cyl, inline = TRUE),
         filter_checkbox("vs", "VS", shared_mtcars, ~vs, inline = TRUE)
       ),
       plotly::ggplotly(shared_mtcars %>% 
                          ggplot(aes(x = mpg,group=paste0(cyl,vs))) + 
                          geom_histogram(fill = "pale green",
                                         color = "black") + 
                          theme(legend.position = "none"))
)
