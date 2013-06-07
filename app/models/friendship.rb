class Friendship < ActiveRecord::Base
	belongs_to :player
	belongs_to :friend, class_name: "Player"
	
	scope :pending, lambda {where(pending: true)}
	scope :mutual, lambda {where(mutual: true)}
end
