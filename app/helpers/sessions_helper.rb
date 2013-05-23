module SessionsHelper
	def sign_in(player)
		cookies.permanent[:remember_token] = player.remember_token
		self.current_player = player
	end
	
	def sign_out
		cookies.delete(:remember_token)
		self.current_player = nil
	end
	
	def authenticate
		deny_access unless signed_in?
	end
	
	def deny_access
		redirect_to signin_path, :notice => "You must sign-in before accessing this page."
	end
	
	def signed_in?
		current_player
	end
	
	def current_player?(player)
		player == current_player
	end
	
	def current_player=(player)
		@current_player = player
	end
	
	def current_player()
		@current_player ||= Player.find_by(remember_token: cookies[:remember_token])
	end
end
