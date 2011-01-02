module TimeHack
  attr_writer :hour, :min
  
  def self.included(active_record)
    active_record.before_save :set_time
  end
  
  def hour
    format time.hour if time
  end
  
  def min
    format time.min if time
  end
  
  private
  def format d
    sprintf("%02d",d)
  end
  
  def set_time
    self.time= @hour.blank? ? nil : Time.local(0,1,1,@hour,@min.blank? ? 0 : @min)
  end
end