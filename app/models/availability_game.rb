# == Schema Information
#
# Table name: availability_games
#
#  game_id         :integer
#  availability_id :integer
#

class AvailabilityGame < ActiveRecord::Base
	belongs_to :availability
	belongs_to :game
end
