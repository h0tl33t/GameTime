class FriendshipsController < ApplicationController
	def create
		friend = Player.find(params[:friend_id])
		@friendship = current_player.friendships.build(friend_id: friend.id) unless Friendship.between(current_player, friend).exists?
		
		if @friendship.save
			if Friendship.between(friend, current_player).exists?
				Friendship.between(friend, current_player).first.update_attributes(pending: false, mutual: true)
				@friendship.update_attributes(pending: false, mutual: true)
			else
				GametimeMailer.pending_friend_request(@friendship.friend, current_player).deliver
			end
			flash[:notice] = 'Added friend.'
			redirect_to current_player
		else
			flash[:error] = 'Unable to add friend.'
			redirect_to players_path
		end
	end
	
	def update #Update called when denying a mutual_friendship with pending = true
		@mutual_friendship = current_player.mutual_friendships.find(params[:id])
		@mutual_friendship.update_attribute(:pending, false)
		flash[:notice] = 'Friendship denied.'
		redirect_to current_player
	end
  
	def destroy
		@friendship = current_player.friendships.find(params[:id])
		Friendship.between(@friendship.friend, current_player).first.destroy if Friendship.between(@friendship.friend, current_player).exists?
		@friendship.destroy
		flash[:notice] = 'Friendship destroyed.'
		redirect_to current_player
	end
end
