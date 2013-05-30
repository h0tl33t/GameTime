# == Schema Information
#
# Table name: availabilities
#
#  id         :integer          not null, primary key
#  start_at   :datetime
#  end_at     :datetime
#  created_at :datetime
#  updated_at :datetime
#

class Availability < ActiveRecord::Base
	has_event_calendar
	belongs_to :player
	has_and_belongs_to_many :games
	
	def color
      self[:color] || '#70a9a0'
    end
end
