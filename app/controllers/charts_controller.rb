#require("chartdirector")

class ChartsController < ApplicationController
  before_filter :login_required
  
  def smaller x, y
    x && y && x < y
  end
  
  def calculate_fertility_end data
    i=6
    while i< data.size - 3
      sixth_lowest = data[0,i-1].sort {|x,y| x ? y ? x<=>y : -1 : y ? 1 : 0}[5]
      if smaller(sixth_lowest, data[i]) &&
        smaller(sixth_lowest, data[i+1]) &&
        smaller(sixth_lowest, data[i+2])
        if smaller(sixth_lowest, data[i+2] - 0.2)
          return i+2
        else
          if smaller(sixth_lowest, data[i+3])
            return i+3
          end
        end 
      end
      i+=1
    end
    return data.size
  end
  
  #
  # Render and deliver the chart
  #
  def cycle()
    cycle = Cycle.find_by_user_and_date(current_user, Date.parse(params[:id]))
    if cycle == nil
      send_chart_data ChartDirector::XYChart.new(0,0)
      return
    end
    days = cycle.days
    ch = days.inject(Hash.new(nil)) do |h,d|
      h[d.date]=d.temperature if d.temperature
      h
    end
    data = (cycle.start..cycle.ende).map {|d| ch[d] }
    fertility_end = calculate_fertility_end data
    
    puts "Fertility " + cycle.fertility_begin.to_s + ".." + fertility_end.to_s
    
    data = data.map {|t| t || ChartDirector::NoValue}
    
    bottom_labels = (1..cycle.length).to_a
    top_labels = (cycle.start...cycle.ende).map {|d| d.day}
    
    grid = 15
    min_size = 0.6
    max_size = 1.2
    default_mean = 36.8
    scale = 0.05

    min_temp = default_mean - max_size/2
    max_temp = default_mean + max_size/2

    actual_min = cycle.min || default_mean
    actual_max = cycle.max || default_mean
    actual_range = actual_max - actual_min
    actual_mean = (actual_max + actual_min)/2
    
    if actual_range + 2*scale <= min_size
      min_temp = actual_mean - min_size/2
      max_temp = actual_mean + min_size/2
    elsif  actual_range + 2*scale <= max_size
      min_temp = actual_min - scale
      max_temp = actual_max + scale
    elsif actual_min >= min_temp
      min_temp = actual_min
      max_temp = actual_min + max_size
    elsif actual_max <= max_temp  
      min_temp = actual_max - max_size
      max_temp = actual_max
    end
    
    width = data.size * grid
    height = (max_temp - min_temp) / scale * grid
    left,top, right, bottom= 50, 70, 40, 50
    yLabels = ((min_temp/scale).round..(max_temp/scale).round).map{|x| sprintf("%2.2f",x*scale)}
    
    c = ChartDirector::XYChart.new(width + left + right, height + top + bottom, 0xffdddd, 0x000000, 1)
    c.setRoundedFrame()
    
    # Set directory for loading images to current script directory
    c.setSearchPath(File.dirname(__FILE__) + "/../../public/images")
    
    # Set the plotarea at (55, 58) and of size 520 x 195 pixels, with white (ffffff)
    # background. Set horizontal and vertical grid lines to grey (cccccc).
    c.setPlotArea(left, top, width, height, 0xffffff, -1, -1, 0xcccccc, 0xcccccc)
    
    # Add a legend box at (55, 32) (top of the chart) with horizontal layout. Use 9
    # pts Arial Bold font. Set the background and border color to Transparent.
    c.addLegend(55, 32, false, "arialbd.ttf", 9).setBackground(
                                                               ChartDirector::Transparent)
    
    # Add a title box to the chart using 15 pts Times Bold Italic font. The title is
    # in CDML and includes embedded images for highlight. The text is white (ffffff)
    # on a dark red (880000) background, with soft lighting effect from the right
    # side.
    c.addTitle(
            "<*block,valign=absmiddle*><*img=star.png*><*img=star.png*> Cycle " \
            "Starting #{cycle.start}<*img=star.png*><*img=star.png*><*/*>", "timesbi.ttf", 15, 0xffffff
    ).setBackground(0x880000, -1, ChartDirector::softLighting(ChartDirector::Right
    ))
    
    c.yAxis().setTitle("Temperature")
    c.yAxis().setLinearScale2(min_temp, max_temp, yLabels)
    c.xAxis().setTitle("Day of Cycle");
    c.xAxis().setLabels(bottom_labels)
    c.xAxis().addZone(cycle.fertility_begin, fertility_end+0.5, 0xffcc66);
    c.xAxis2().setTitle("Date");
    c.xAxis2().setLabels(top_labels)
    
    # Set the axes width to 2 pixels
    c.xAxis().setWidth(2)
    c.yAxis().setWidth(2)
    
    # Add a spline layer to the chart
    layer = c.addLineLayer(data, 0x982810, "Temperature")
    layer.setGapColor(c.dashLineColor(0x982810))
    
    # Set the default line width to 2 pixels
    layer.setLineWidth(2)
    
    # Add a data set to the spline layer, using brown (982810) as the line color, with
    # pink (f040f0) diamond symbols.
    layer.getDataSet(0).setDataSymbol(ChartDirector::CircleSymbol, 7, 0xf040f0)
    
    # output the chart
    send_chart_data c
  end
  
  private
  def send_chart_data c
    send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png", :disposition => "inline")
  end
  
end
