class SessionsController < ApplicationController
	
	def new
		@title = 'Sign In'
	end
	
	def create
		player = Player.find_by(email: params[:session][:email])
		if player && player.authenticate(params[:session][:password])
			sign_in player
			flash[:success] = "Successfully logged in as #{player.name} (#{player.alias})."
			redirect_to player
		else
			flash.now[:error] = 'Not a valid email/password combination.'
			render 'new'
		end
	end
	
	def destroy
		sign_out
		redirect_to root_path
	end
end
