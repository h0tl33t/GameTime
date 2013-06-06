module AvailabilitiesHelper
=begin
	def calculate_shared_availability(availabilities, players_required)
		events = []
		
		availabilities.sort_by! {|availability| availability.duration}
		#shared_availability = determine_baseline_availability(availabilities)
		
		
		while availabilities.size > 1
			matched_players = []
			shared_availability = availabilities.first #Set initial baseline.
			availabilities.each do |availability|
				overlap_found, shared_availability = availability.find_overlap(shared_availability)
				matched_players << availability.player if overlap_found
			end
			events << [shared_availability, matched_players] unless matched_players.empty?
			availabilities.delete_at(0)
		end
		return events
	end
	
	def determine_baseline_availability(availabilities)
		#Find earliest start and latest end between availabilities.
		earliest_start = availabilities.sort_by {|availability| availability.start_at}.first.start_at
		latest_end = availabilities.sort_by {|availability| availability.end_at}.last.end_at
		availabilities.sort_by {|availability| availability.proximity_to(earliest_start, latest_end)}.first
	end
=end	

	
	def trim_overlapping_shared_availabilities(shared_availabilities)
		#Look at each shared_availability[:availability] and check to see if any of them overlap.
		#When an overlap is found, take the shared_availability[:availability] with less players (shared_availability[:players].size)
		#And adjust the overlapping end point (whether start or end) and move it so that it butts up against the other availability w/ more players
		
		availabilities = shared_availabilities.dup
		availabilities.each_with_index do |baseline, baseline_index|
			availabilities.each_with_index do |availability, index|
				
			end
		end
		while availabilities.size > 1
			shared_availability = availabilities.first #Set initial baseline.
			availabilities.each_with_index do |availability, index|
				overlap_found, shared_availability = availability.find_overlap(shared_availability)
			end
			tentative_events << {availability: shared_availability, game: matched_game, players: matched_players}
			availabilities.delete_at(0)
		end
	end

=begin
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
=end	
end