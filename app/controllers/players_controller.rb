class PlayersController < ApplicationController
	before_action :set_user, only: [:show, :edit, :update, :destroy]
	
	def index
		@players = Player.all
		@title = 'All Players'
	end
	
	def show
		@title = @player.name
	end
	
	def new
		@player = Player.new()
		@title = 'New Player'
	end
	
	def create
		@title = 'Create Player'
		@player = Player.new(player_params)
		if @player.save
			flash[:success] = 'Welcome to GameTime!'
			redirect_to @player
		else
			render 'new'
		end
	end
	
	def update
		if @player.update_attributes(player_params)
			redirect_to @player, :flash => { :success => "Player info updated." }
		else
			@title = "Edit Player Info"
			render 'edit'
		end
	end

	def destroy
		@player.destroy
		redirect_to players_path, :flash => { :success => "Player deleted." }
	end
	
	def edit
		@title = "Edit Player Info"
	end
	
	private
		def set_user
			@player = Player.find(params[:id])
		end
		
		def player_params
			params.require(:player).permit(:name, :email, :alias, :password, :password_confirmation)
		end
end
