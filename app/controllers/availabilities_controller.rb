class AvailabilitiesController < ApplicationController
	before_action :set_availability, only: [:show, :edit, :update, :destroy]
	#after_action :match_availability, only: [:create, :update]

	def index
		@availabilities = current_player.availabilities
	end

	def show
	end

	def new
		@availability = Availability.new
	end

	def edit
	end

	def create
		@availability = Availability.new(availability_params)
		@availability.player = current_player
     
		if @availability.save
			redirect_to @availability, notice: 'Availability was successfully created.'
		else
			render 'new'
		end
	end
  
	def update
		if @availability.update(availability_params)
			redirect_to @availability, notice: 'Availability was successfully updated.'
		else
			render 'edit'
		end
	end

	def destroy
		@availability.destroy
		redirect_to availabilities_url
	end
  
	def match_availability
		active_availabilities = Availability.active
		
		tentative_events = calculate_shared_availability(active_availabilities)
		tentative_events.each do |tentative_event|
			Event.create_from(tentative_event) unless matching_event_exists?(tentative_event)
		end
	end
	
	def calculate_shared_availability(active_availabilities)
		tentative_events = []
		availabilities = active_availabilities.dup
		availabilities.sort_by! {|availability| availability.duration}
		#shared_availability = determine_baseline_availability(availabilities)
		
		while availabilities.size > 1 #Iterate through all active availabilities as sorted by smallest-to-biggest duration, finding overlaps between each of them.
			shared_availability = availabilities.first #Set initial baseline.
			games = shared_availability.games #Need to also baseline the games we'll be looking for for this match iteration.
			matched_players = [shared_availability.player]
			availabilities.each_with_index do |availability, index|
				overlap_found, shared_availability = availability.find_overlap(shared_availability)
				matched_players << availability.player if overlap_found
			end
			matched_players.uniq!
			if matched_players.size > 0
				games.flatten!
				#Currently grabs the most frequently occuring game during the matching.
				frequency = games.inject(Hash.new(0)) do |hash, game|
					hash[game] += 1
					hash
				end
				matched_game = games.sort_by { |game| frequency[game] }.last
				tentative_events << {availability: shared_availability, game: matched_game, players: matched_players}
			end
			availabilities.delete_at(0) #Delete currently smallest as it has been compared against all others, so that the next iteration will compare the new smallest availability.
		end
		#return trim_overlapping_shared_availabilities(tentative_events)
		return tentative_events
	end
	
	def matching_event_exists?(availability_hash)
		Event.where('start_at = ? and end_at = ? and game_id = ?', availability_hash[:availability].start_at, availability_hash[:availability].end_at, availability_hash[:game].id).exists?
	end
	
	def trim_overlapping_shared_availabilities(shared_availabilities)
		#Look at each shared_availability[:availability] and check to see if any of them overlap.
		#shared_availability[:availability].duration
		
	end

  private
	def set_availability
		@availability = Availability.find(params[:id])
    end

    def availability_params
		params.require(:availability).permit(:start_at, :end_at, :game_ids => [])
    end
end
