class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = Event.all
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
		availability = Availability.find(params[:availability])
		players = params[:players].map{|player_id| Player.find(player_id)}
		@event = Event.create(name: 'Join Up Event Test', start_at: availability.start_at, end_at: availability.end_at, game: availability.games.first)
		@event.players = players
		GametimeMailer.gametime_event_created(@event).deliver
    redirect_to events_path, notice: 'Successfully joined up and started a GameTime Event!'
  end

  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:name, :game_id, :start_at, :end_at, :player_ids)
    end
end
