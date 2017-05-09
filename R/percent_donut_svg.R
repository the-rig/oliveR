percent_donut_svg = function(proportion = .5
                                ,fill = c("#FC4A1A", "#dfdce3")
                                ,thickness_out = 4
                                ,thickness_in = 3
                                ,inner_radius = 50
                                ,outer_radius = 100){
  
  dat <- data.frame(inner = inner_radius
                    ,outer = outer_radius
                    ,fill = fill
                    ,proportions = c(proportion, 1-proportion)
  ) %>% 
    mutate(ymax = c(proportions[1], 1)
           ,ymin =  c(0, proportions[2])
  )
  
  plot <- dat %>%     
    ggplot(aes(fill=fill
               ,ymax=ymax
               ,ymin=ymin
               ,xmax=thickness_out
               ,xmin=thickness_in)) +
    scale_fill_manual(values = fill) +
    coord_polar(theta='y') +
    xlim(c(0
           ,thickness_out)) +
    theme_void() +
    guides(fill = 'none') +
    geom_rect() 
  
  grob <- ggplotGrob(plot)
  
  gridsvg(sys.frame(1))
  
  grid.draw(grob)
  
  svg <- grid.export(name = NULL
                     ,htmlWrapper = TRUE)
  
  svg_only <- paste0(capture.output(svg$svg, file = NULL), collapse = '\n')
  #svg_only <- svg$svg
  
  grDevices::dev.off(which = dev.cur())
  
  return(svg_only)
  
}