module CyclesHelper
  def reading_options
    [[ "Oral",1],
    ["Rectal", 2],
    ["Vaginal", 3]]
  end
  
  def reading option
    reading_options.each {|a| return a[0] if a[1] == option} if option
  end
end
