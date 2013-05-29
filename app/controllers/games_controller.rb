class GamesController < ApplicationController
	before_action :set_game, only: [:show, :edit, :update, :destroy]
	before_action :check_admin, :only => [:new, :create, :edit, :update, :destroy]
	
	def index
		set_games
		@title = 'All Games'
	end
	
	def show
		@title = @game.name
	end
	
	def new
		@game = Game.new()
		@title = 'New Game'
	end
	
	def create
		@title = 'Create Game'
		@game = Game.new(game_params)
		if @game.save
			flash[:success] = "Added #{@game.name}!"
			redirect_to @game
		else
			render 'new'
		end
	end
	
	def update
		if @game.update_attributes(game_params)
			redirect_to @game, :flash => { :success => "Game updated." }
		else
			@title = "Edit Game"
			render 'edit'
		end
	end

	def destroy
		@game.destroy
		redirect_to root_path, :flash => { :success => "Game deleted." }
	end
	
	def edit
		@title = "Edit Game Info"
	end
	
	private
		def set_game
			begin
				@game = Game.find(params[:id])
			rescue
				redirect_to root_path, :notice => "Game could not be found."
			end
		end
		
		def set_games
			@games = Game.all
		end
		
		def check_admin
			if current_player
				redirect_to root_path, :notice => "Must be logged in as an administrator to access that page." unless current_player.admin?
			end
		end
		
		def game_params
			params.require(:game).permit(:name, :platform, :players_required)
		end
end
