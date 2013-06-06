# == Schema Information
#
# Table name: availabilities
#
#  id         :integer          not null, primary key
#  start_at   :datetime
#  end_at     :datetime
#  created_at :datetime
#  updated_at :datetime
#  player_id  :integer
#

class Availability < ActiveRecord::Base
	has_event_calendar
	belongs_to :player
	has_and_belongs_to_many :games
	
	scope :active, lambda { where("start_at >= ?", DateTime.now) }
	
	#Availabilities with player_id matching passed player.id
	scope :belongs_to, lambda { |availability| where('player_id = ? and id != ?', availability.player_id, availability.id) }
	
	#Availabilities that start before a passed availability
	scope :starts_before, lambda { |availability| where('start_at < ? and id != ?', availability.start_at, availability.id) }
	
	#Availabilities with start datetimes between a passed availability's start and end datetime.
	scope :start_overlap, lambda { |availability| where('start_at > ? and start_at < ? and id != ?', availability.start_at, availability.end_at, availability.id) }
	
	#Availabilities with end dates after a passed availability's start date.
	scope :end_overlap, lambda { |availability| where('end_at > ? and end_at < ? and id != ?', availability.start_at, availability.end_at, availability.id) }
	
	validates :games, presence: true
	validate :does_not_overlap
	validate :starts_in_future
	validate :ends_after_start
	validate :minimum_duration
	
	def color
      self[:color] || '#70a9a0'
    end
	
	def does_not_overlap
		#For the given player attempting to create a new availability, ensure the following:
		#	If the new availability starts before another existing availability, the new availability's end time cannot occur between the existing availability's start and end.
		#	The new availability cannot start during an existing availability (between its start and end).
		
		if Availability.belongs_to(self).end_overlap(self).exists? or Availability.belongs_to(self).start_overlap(self).exists?
			errors.add( :base, "Availabilities cannot overlap.")
		end
	end
	
	def starts_in_future
		unless self.start_at > DateTime.now
			errors.add( :base, "Availabilities should not start in the past.")
		end
	end
	
	def ends_after_start
		unless self.end_at > self.start_at
			errors.add( :base, "Availabilities must end after the start time.")
		end
	end
	
	def minimum_duration
		unless self.duration >= 1.hour
			errors.add( :base, "Availabilities must have a minimum duration of 1 hour.")
		end
	end
	
	def find_overlap(baseline) #Determine if an availability overlaps with a baseline availability and if so, return the start and end datetime's for the overlap window.
		unless self.start_at > baseline.end_at or self.end_at < baseline.start_at or self.id == baseline.id
			self.start_at < baseline.start_at ? overlap_start = baseline.start_at : overlap_start = self.start_at
			self.end_at > baseline.end_at ? overlap_end = baseline.end_at : overlap_end = self.end_at
			
			if (overlap_end - overlap_start) >= 1.hour
				overlap_availability = Availability.new
				overlap_availability.start_at, overlap_availability.end_at = overlap_start, overlap_end
				return true, overlap_availability
			else
				return false, baseline
			end
		else
			return false, baseline
		end
	end
	
	def duration
		self.end_at - self.start_at
	end
	
	def proximity_to(start_point, end_point)
		#Given a starting point and an end point, returns the number of minutes for how far away an availability's own start and end points are.
		((self.start_at - start_point)*24*60).to_i.abs + ((self.end_at - end_point)*24*60).to_i.abs
	end
end
