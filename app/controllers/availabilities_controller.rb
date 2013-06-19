class AvailabilitiesController < ApplicationController
	before_action :set_availability, only: [:show, :edit, :update, :destroy]
	before_action :verify_owner, only: [:edit, :update, :destroy]
	before_action :verify_friends, only: [:show]

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
			redirect_to player_availability_path(current_player, @availability), notice: 'Availability was successfully created.'
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
		redirect_to player_availabilities_path
	end

  private
	def set_availability
		@availability = Availability.find(params[:id])
    end

    def availability_params
		params.require(:availability).permit(:start_at, :end_at, :game_ids => [])
    end
	
	def verify_friends
		
		unless @availability.player.mutual_friends_with?(current_player) or @availability.player == current_player
			redirect_to root_path, notice: "You must be mutual friends to see another player's availabilities."
		end
	end
	
	def verify_owner
		unless @availability.player == current_player
			redirect_to root_path, notice: "You cannot modify another player's availability."
		end
	end
end
