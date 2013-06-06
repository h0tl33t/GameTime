class AvailabilitiesController < ApplicationController
	before_action :set_availability, only: [:show, :edit, :update, :destroy]
	after_action :match_availability, only: [:create, :update]

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
		
		while availabilities.size > 1
			matched_players = []
			games = []
			shared_availability = availabilities.first #Set initial baseline.
			availabilities.each_with_index do |availability, index|
				overlap_found, shared_availability = availability.find_overlap(shared_availability)
				if overlap_found
					matched_players << availability.player #Add player for current availability
					matched_players << availabilities[index-1].player #Since match was found with last availability, add that player as well.
					games << availability.games
				end
			end
			unless matched_players.empty? and games.empty?
				matched_players.uniq!
				games.flatten!
				#Currently grabs the most frequently occuring game during the matching.
				frequency = games.inject(Hash.new(0)) do |hash, game|
					hash[game] += 1
					hash
				end
				matched_game = games.sort_by { |game| frequency[game] }.last
				tentative_events << {availability: shared_availability, game: matched_game, players: matched_players}
			end
			availabilities.delete_at(0)
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
