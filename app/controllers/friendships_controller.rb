class FriendshipsController < ApplicationController
	def create
		@friendship = current_player.friendships.build(friend_id: params[:friend_id])
		
		if @friendship.save
			if current_player.mutual_friends.include?(@friendship.friend)
				mutual_friend = @friendship.friend
				@friendship.update_attributes(pending: false, mutual: true)
				mutual_friend.friendships.select{|friendship| friendship.friend = current_player}.first.update_attributes(pending: false, mutual: true)
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
		if @friendship.mutual
			mutual_friend = @friendship.friend
			mutual_friend.friendships.select{|friendship| friendship.friend = current_player}.first.update_attributes(pending: true, mutual: false)
		end
		@friendship.destroy
		flash[:notice] = 'Friendship destroyed.'
		redirect_to current_player
	end
end
