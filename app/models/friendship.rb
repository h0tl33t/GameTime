class Friendship < ActiveRecord::Base
	belongs_to :player
	belongs_to :friend, class_name: "Player"
	
	scope :pending, lambda {where(pending: true)}
	scope :mutual, lambda {where(mutual: true)}
	scope :between, lambda {|initiator, acceptor| where('player_id = ? and friend_id = ?', initiator.id, acceptor.id)}
	
	validates_uniqueness_of :player_id, :scope => [:friend_id]
end
