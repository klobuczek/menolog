module DaysHelper
  def menses_options
    [[ "Spotting",Day::MENSES_SPOTTING],
    ["Light", Day::MENSES_LIGHT],
    ["Medium", Day::MENSES_MEDIUM],
    ["Heavy", Day::MENSES_HEAVY]]
  end
  def cf_feeling_options
    [[ "Dry",1],
    ["Humid", 2],
    ["Wet", 3],
    ["Slippery", 4]]
  end
  def cf_appearance_options
    [[ "Sticky",1],
    ["Creamy", 2],
    ["Watery", 3],
    ["Eggwhite", 4]]
  end
  def c_position_options
    [[ "Low",1],
    ["Medium", 2],
    ["High", 3]]
  end
  def c_opening_options
    [[ "Closed",1],
    ["Medium", 2],
    ["Open", 3]]
  end
  def c_texture_options
    [[ "Firm",1],
    ["Medium", 2],
    ["Soft", 3]]
  end
  def every_5_min
    (0..11).map {|m| sprintf("%02d",5*m)}
  end
end
