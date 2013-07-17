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
	scope :starting_today, lambda { where('start_at >= ? and start_at <= ?', Time.zone.now.at_beginning_of_day, Time.zone.now.end_of_day) }
	
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
		def reminder
			Event.starting_today.each {|e| GametimeMailer.gametime_event_reminder(e).deliver }
		end
		
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
	end
end
