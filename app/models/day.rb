class Day < ActiveRecord::Base
  include TimeHack
  NONE = 0
  
  MENSES_SPOTTING = 1
  MENSES_LIGHT = 2
  MENSES_MEDIUM = 3
  MENSES_HEAVY = 4
  
  belongs_to :user
  has_one :cycle, :dependent => :destroy
  before_save :handle_cycle

  def to_param
    date.to_s
  end
  
  private
  def handle_cycle
    if first
      if cycle.nil?
        build_cycle
      end
    else 
      if !cycle.nil?
        cycle.destroy
      end
    end
  end
  
end
