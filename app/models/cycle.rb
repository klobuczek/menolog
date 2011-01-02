class Cycle < ActiveRecord::Base
  belongs_to :day
  
  attr_writer :cycles, :index
  @@maxCycleLength = 40
  @@defaultCycleLength = 28
  @@minCycleLength = 14
  
  def self.find_by_user(user)
    cycles=Cycle.find(:all, :include => :day, :conditions=> ["user_id = ?", user.id], :order => "date" )
    cycles.each_with_index do |c,i|
      c.index=i
      c.cycles=cycles
    end
    cycles
  end
  
  def self.find_by_user_and_date(user, date)
    self.find_by_user(user).reverse_each {|c| return c if date.between?(c.start, c.ende-1)}
    nil
  end
  
  def self.find_by_user_and_id(user, id)
    self.find_by_user(user).each {|c| return c if (c.id == id)}
    nil
  end
  
  def start
    day.date
  end
  
  def ende
    [start + @@maxCycleLength, next_cycle ? next_cycle.start : [Date.today() + 1 ,start+@@defaultCycleLength].max].min
  end
  
  def length
    ende - start
  end
  
  def days
    @days||=Day.find(:all, :conditions=> {:user_id => day.user_id, :date => start..ende}, :order => :date )
  end
  
  def min
    temperatures.min unless temperatures.empty?
  end
  
  def max
    temperatures.max unless temperatures.empty?  
  end
  
  def fertility_begin
    cycle=previous_cycle
    return 0 if (cycle.nil? || !cycle.proper_cycle? || cycle.anovulatory_cycle?)
    
    min_length = @@maxCycleLength
    cycle_count = 1
    begin
      cycle_count += 1 if cycle.proper_cycle?
      min_length = [cycle.length, min_length].min
    end while (cycle=cycle.previous_cycle) && cycle_count <= 12
    
    [0,
    case cycle_count
      when 1..3: 0
      when 4..6: [min_length - 21, 5].min 
      when 7..12: min_length - 21
    else min_length - 20
    end
    ].max
  end
  
  protected
  def proper_cycle?
    next_cycle.start - start <= @@maxCycleLength
  end
  
  def anovulatory_cycle?
    false # && check that last fertility ends before cycle end
  end
  
  def previous_cycle
    @cycles[@index-1] if @index > 0
  end

  private
  def temperatures
    @temperatures ||= days.map {|d| d.temperature}.delete_if {|x| x.nil?}
  end
  
  def next_cycle
    @cycles[@index+1]
  end
end