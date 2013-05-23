class PlayersController < ApplicationController
	before_action :set_player, only: [:show, :edit, :update, :destroy]
	before_action :authenticate, :only => [:index, :edit, :update, :destroy, :show]
	before_action :correct_player, :only => [:show, :edit, :update]
	
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
			sign_in(@player)
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
		def set_player
			begin
				@player = Player.find(params[:id])
			rescue
				redirect_to root_path, :notice => "Player profile could not be found."
			end
		end
		
		def correct_player
			unless current_player?(@player)
				redirect_to root_path, :notice => 'You are not authorized to view that page.'
			end
		end
		
		def player_params
			params.require(:player).permit(:name, :email, :alias, :password, :password_confirmation)
		end
end
