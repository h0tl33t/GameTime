class PlayersController < ApplicationController
	def new
		@player = Player.new(player_params)
	end
	
	def create
		@player = Player.new(player_params)
	end
	
	def update
		@player = Player.update(player_params)
	end
	
	private
	
	def player_params
		params.require(:player).permit(:name, :email, :alias, :password, :password_confirmation)
	end
end
