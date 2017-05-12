percent_donut_svg = function(proportion = .4
                                ,fill = c("#FC4A1A", "#dfdce3")
                                ,thickness_out = 4
                                ,thickness_in = 3
                                ,inner_radius = 50
                                ,outer_radius = 100){
  
  # Create test data.
  dat <- data.frame(prop=c(proportion, 1-proportion))
  
  # Add addition columns, needed for drawing with geom_rect.
  dat$fraction <- dat$prop / sum(dat$prop)
  dat <- dat[order(dat$fraction), ]
  dat$ymax <- cumsum(dat$fraction)
  dat$ymin <- c(0, head(dat$ymax, n=-1))
  
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
  
  # svg <- grid.export(name = 'test.svg'
  #                    ,htmlWrapper = TRUE)
  
  grid.export(name = NULL
                     ,htmlWrapper = TRUE)
  
  #svg_only <- paste0(capture.output(svg$svg, file = NULL), collapse = '\n')
  #svg_only <- svg$svg
  
  grDevices::dev.off(which = dev.cur())
  
  return(svg_only)
  
}