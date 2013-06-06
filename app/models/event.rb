# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  start_at   :datetime
#  end_at     :datetime
#  created_at :datetime
#  updated_at :datetime
#  game_id    :integer
#

class Event < ActiveRecord::Base
	has_event_calendar
	belongs_to :game
	has_and_belongs_to_many :players
	
	validate :game, presence: true
	validate :minimum_duration
	
	scope :starts_before, lambda { |event| where('start_at < ? and game_id = ?', event.start_at, event.game_id) }
	scope :starts_after, lambda { |event| where('start_at > ? and game_id = ?', event.start_at, event.game_id) }
	scope :ends_before, lambda { |event| where('end_at < ? and game_id = ?', event.end_at, event.game_id) }
	scope :ends_after, lambda { |event| where('end_at > ? and game_id = ?', event.end_at, event.game_id) }
	scope :start_overlap, lambda { |event| where('start_at >= ? and start_at <= ? and game_id = ?', event.start_at, event.end_at, event.game_id) }
	scope :end_overlap, lambda { |event| where('end_at >= ? and game_id = ?', event.start_at, event.game_id) }
	
	def duration
		self.end_at - self.start_at
	end
	
	def minimum_duration
		unless self.duration >= 1.hour
			errors.add( :base, "Events must have a minimum duration of 1 hour.")
		end
	end
	
	def check_for_existing_events
		overlapping_events = []
		[1,2,3,4].each do |type|
			events_found = self.find_overlaps(type)
			overlapping_events << self.parse_overlapping_events(events_found, type) unless events_found.empty?
		end
		
		if overlapping_events.empty?
			self.save
		else
			overlapping_events.flatten!.uniq!	
			self.handle_overlapping_events(overlapping_events)
		end
		self.save
	end
	
	def find_overlaps(type)
		case type
		when 1
			Event.starts_before(self).end_overlap(self)
		when 2
			Event.start_overlap(self)
		when 3
			Event.starts_after(self).ends_before(self)
		when 4
			Event.starts_before(self).ends_after(self)
		end
	end
		
	def calculate_overlap_duration(event, type)
		case type
		when 1
			event.end_at - self.start_at
		when 2
			self.end_at - event.start_at
		when 3
			event.end_at - event.start_at
		when 4
			self.end_at - self.start_at
		end
	end
		
	def parse_overlapping_events(events, type)
		overlapping_events = []
		overlapping_event = {}
		events.each do |event|
			overlapping_event[:event] = event
			overlapping_event[:overlap_duration] = self.calculate_overlap_duration(event, type)
			overlapping_event[:type] = type
				
			overlapping_events << overlapping_event.dup
			overlapping_event.clear
		end
		return overlapping_events
	end
		
	def handle_overlapping_events(overlapping_events)
		#Handle two overlapping events (Type 1 and Type 2, or Type 1/2 and a Type 3)
		if overlapping_events.size > 1 #Multiple events land inside the new event
			overlapping_events.each do |event|
				if event[:overlap_duration] >= 1.hour #If an existing event at least an hour, add the player to the event.
					event[:event].players << self.players 
					self.players.each {|player| event[:event].players << player unless event[:event].players.include?(player)}
				end
			end
		elsif overlapping_events.size == 1 #Handle single overlapping event.
			case overlapping_events.first[:type]
			when 1
				if overlapping_events.first[:overlap_duration] >= 1.hour
					overlapping_events.first[:event].start_at = self.start_at
					self.players.each {|player| overlapping_events.first[:event].players << player unless overlapping_events.first[:event].players.include?(player)}
					overlapping_events.first[:event].save
				else
					self.start_at = overlapping_events.first[:event].end_at
					self.save
				end
			when 2
				if overlapping_events.first[:overlap_duration] >= 1.hour
					overlapping_events.first[:event].end_at = self.end_at
					self.players.each {|player| overlapping_events.first[:event].players << player unless overlapping_events.first[:event].players.include?(player)}
					overlapping_events.first[:event].save
				else
					self.end_at = overlapping_events.first[:event].start_at
					self.save
				end
			when 3
				self.players.each {|player| overlapping_events.first[:event].players << player unless overlapping_events.first[:event].players.include?(player)}
				overlapping_events.first[:event].save
			when 4
				overlapping_events.first[:event].start_at = self.start_at
				overlapping_events.first[:event].end_at = self.end_at
				self.players.each {|player| overlapping_events.first[:event].players << player unless overlapping_events.first[:event].players.include?(player)}
				overlapping_events.first[:event].save
			end
		end
	end
	
	class << self
		def create_from(event_hash) #event_hash contains :availability (Availability), :game (Game), :players (array of Player)
			new_event = Event.new
			new_event.name = "#{event_hash[:game].name} Event"
			new_event.start_at = event_hash[:availability].start_at
			new_event.end_at = event_hash[:availability].end_at
			new_event.game = event_hash[:game]
			new_event.players << event_hash[:players]
		
			#check_for_existing_events(new_event)
			new_event.check_for_existing_events
			#new_event.save
		end
		
			#Given a new event, we want the result to be the greatest possible duration (maximizing player's availabilities).
			#First, we need to decide whether or not to add the new event's players to an existing event or create a new event.
			#Creating a new event in this case would require altering the existing overlapping events' start and end times.
			#To make the decision, need to determine the resulting duration for each of the following scenarios:
			#	Existing event starts before new event and ends during the new event. (Type 1)
			#	Existing event starts during the new event and ends after the new event. (Type 2)
			#	Existing event starts and ends during the new event. (Type 3)
			#	Existing event starts before and ends after the new event. (Type 4)
			#Given the nature of events, each only having one game and not being able to overlap, the worst case scenarios involve two overlapping events:
			#	Type 1 and Type 2 event both land inside our new event (possibly directly adjacent)
			#	Type 1 OR Type 2 and also a Type 3 land inside our new event (possibly directly adjacent)
			#	To handle this, we would need to figure out which event has the bigger overlap...then add new event players and start/end to that one.
			#Worst case scenarios aside, the other scenarios we simply run into a single overlap of any of the 4 Types.
			#Handling overlap scenarios:
			#Type 1:
			#	First, subtract existing.end_at from new.start_at.
			#	If result < 1 hr, move new.start_at to existing.end_at and create a new event.
			#	If result >= 1 hr, set existing.start_at to new.start_at and add players from new event to existing.
			#Type 2:
			#	First, subtract start.end_at from existing.start_at.
			#	If result < 1 hr, move new.end_at to existing.start_at and create a new event.
			#	If result >= 1 hr, set existing.end_at to new.end_at and add players from new event to existing.
			#Type 3:
			#	Add all players from new event to existing event.
			#Type 4:
			#	Update existing.start_at and .end_at to the values from new.event and add players from new event to existing.
=begin			
		def check_for_existing_events(new_event)
			overlapping_events = []
			[1,2,3,4].each do |type|
				events_found = find_overlaps(new_event, type)
				overlapping_events << parse_overlapping_events(events_found, new_event, type) if events_found
			end
			if overlapping_events.empty?
				new_event.save
			else
				overlapping_events.flatten!.uniq!	
				handle_overlapping_events(overlapping_events, new_event)
			end
		end
		
		def parse_overlapping_events(events, new_event, type)
			overlapping_events = []
			overlapping_event = {}
			events.each do |event|
				overlapping_event[:event] = event
				overlapping_event[:overlap_duration] = calculate_overlap_duration(event, new_event, type)
				overlapping_event[:type] = type
					
				overlapping_events << overlapping_event.dup
				overlapping_event.clear
			end
			return overlapping_events
		end

		def find_overlaps(new_event, type)
			case type
			when 1
				Event.starts_before(new_event).end_overlap(new_event)
			when 2
				Event.start_overlap(new_event)
			when 3
				Event.starts_after(new_event).ends_before(new_event)
			when 4
				Event.starts_before(new_event).ends_after(new_event)
			end
		end
		
		def calculate_overlap_duration(event, new_event, type)
			case type
			when 1
				event.end_at - new_event.start_at
			when 2
				new_event.end_at - event.start_at
			when 3
				event.end_at - event.start_at
			when 4
				new_event.end_at - new_event.start_at
			end
		end
		
		def handle_overlapping_events(overlapping_events, new_event)
			#Handle two overlapping events (Type 1 and Type 2, or Type 1/2 and a Type 3)
			if overlapping_events.size > 1 #Multiple events land inside the new event
				overlapping_events.each do |event|
					event[:event].players << new_event.players if event[:overlap_duration] >= 1.hour #If an existing event at least an hour, add the player to the event.
				end
			elsif overlapping_events.size == 1 #Handle single overlapping event.
				case overlapping_events.first[:type]
				when 1
					if overlapping_events.first[:overlap_duration] >= 1.hour
						overlapping_events.first[:event].start_at = new_event.start_at
						overlapping_events.first[:event].players << new_event.players
						overlapping_events.first[:event].players.uniq!
						overlapping_events.first[:event].save
					else
						new_event.start_at = overlapping_events.first[:event].end_at
						new_event.save
					end
				when 2
					if overlapping_events.first[:overlap_duration] >= 1.hour
						overlapping_events.first[:event].end_at = new_event.end_at
						overlapping_events.first[:event].players << new_event.players
						overlapping_events.first[:event].players.uniq!
						overlapping_events.first[:event].save
					else
						new_event.end_at = overlapping_events.first[:event].start_at
						new_event.save
					end
				when 3
					overlapping_events.first[:event].players << new_event.players
					overlapping_events.first[:event].players.uniq!
					overlapping_events.first[:event].save
				when 4
					overlapping_events.first[:event].start_at = new_event.start_at
					overlapping_events.first[:event].end_at = new_event.end_at
					overlapping_events.first[:event].players << new_event.players
					overlapping_events.first[:event].players.uniq!
					overlapping_events.first[:event].save
				end
			end
		end
=end
	end
end
