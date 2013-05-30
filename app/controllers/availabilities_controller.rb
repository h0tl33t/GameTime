class AvailabilitiesController < ApplicationController
  before_action :set_availability, only: [:show, :edit, :update, :destroy]

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

  private
    def set_availability
      @availability = Availability.find(params[:id])
    end

    def availability_params
      params.require(:availability).permit(:start_at, :end_at, :game_ids)
    end
end
