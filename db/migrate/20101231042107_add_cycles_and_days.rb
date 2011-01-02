class AddCyclesAndDays < ActiveRecord::Migration
  def self.up
    create_table "cycles", :force => true do |t|
      t.integer "day_id",        :null => false
      t.integer "reading"
      t.boolean "contraception"
    end

    create_table "days", :force => true do |t|
      t.integer "user_id",                   :null => false
      t.date    "date",                      :null => false
      t.time    "time"
      t.boolean "first"
      t.float   "temperature"
      t.integer "intercourse"
      t.integer "mensing"
      t.integer "cervical_fluid_feeling"
      t.integer "cervical_fluid_appearance"
      t.integer "cervix_position"
      t.integer "cervix_opening"
      t.integer "cervix_texture"
      t.boolean "ovulation_pain"
      t.boolean "tender_breasts"
      t.boolean "fever"
      t.boolean "lack_of_sleep"
    end
  end

  def self.down
    drop_table :cycles
    drop_table :days
  end
end
