# == Schema Information
#
# Table name: games
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  platform         :string(255)
#  players_required :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Game < ActiveRecord::Base
	validates :name, presence: true
	validates :platform, presence: true
	validates :players_required, presence: true, :numericality => {only_integer: true}
end
