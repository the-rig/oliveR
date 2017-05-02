#' Display a donut plot based on a proportion. 
#'
#' Given a proportion (between 0 and 1), displays a donut plot using functions from the \pkg{ggvis} library. 
#' 
#' @param inner_radius The inner radius of the donut, in pixels. Defaults to 50. 
#' @param outer_radius The outer radius of the donut, in pixels. Defaults to 100. 
#' @param stroke The stroke color (i.e. outline) of the donut. Defaults to NA.
#' @param stroke The stroke color (i.e. outline) of the donut. Defaults to NA.
#' @param fill.hover The colors (from 'right' to 'left') of each segment of the donut to display when the mouse cursor hovers over a segment. Should be less than or equal to 2. Defaults to c("#e24217", '#c8c6cc').
#' @param fill The colors (from 'right' to 'left') of each segment of the donut to display when no mouse cursor is present. Should be less than or equal to 2. Defaults to c('#FC4A1A', '#dfdce3').
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @seealso \code{\link{prop_to_radians}}
#' @export
#' @examples
#' ggvis_donut(.5)


ggvis_donut <- function(proportion
                        ,inner_radius = 50
                        ,outer_radius = 100
                        # ,font_size = '22px'
                        # ,font_family = 'Open Sans'
                        ,stroke = NA
                        # ,tooltip = TRUE
                        ,fill.hover= c("#e24217", '#c8c6cc')
                        ,fill= c('#FC4A1A', '#dfdce3')){
  
  plot <- data.frame(init = c(0, prop_to_radians(proportion))
                     ,end = c(prop_to_radians(proportion), 2*pi)
                     ,inner = inner_radius
                     ,outer = outer_radius
                     ,x = 0.5
                     ,y =0.5
                     ,id = 1:2
                     ,fill = fill
                     ,fill.hover = fill.hover
                     ,proportion = c(proportion, 1-proportion)
  ) %>%
    ggvis(~x, ~y, key := ~id) %>% 
    layer_arcs(
      startAngle :=~init
      ,endAngle :=~end
      ,innerRadius :=~ inner
      ,outerRadius :=~outer
      ,stroke:= stroke
      ,fill.hover:= ~fill.hover
      ,fill:= ~fill) %>% 
    scale_numeric("x", domain = c(0,1)) %>% 
    scale_numeric("y", domain = c(0,1)) %>% 
    hide_axis("x") %>% 
    hide_axis("y")

  return(plot)
  
}
