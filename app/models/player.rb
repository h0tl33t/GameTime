# == Schema Information
#
# Table name: players
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  alias           :string(255)
#  email           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#

class Player < ActiveRecord::Base
	belongs_to :game
	has_many :availabilities, dependent: :destroy
	has_and_belongs_to_many :events
	has_many :friendships, dependent: :destroy
	has_many :friends, through: :friendships
	has_many :mutual_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
	has_many :mutual_friends, through: :mutual_friendships, source: :player
		
	has_secure_password
	
	before_save {|player| player.email.downcase!}
	before_save :create_remember_token
	
	validates :name, presence: true, length: {maximum: 50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
	validates :alias, presence: true
	validates :password, presence: true, length: {minimum: 6}
	validates :password_confirmation, presence: true
	
	def mutual_friends_with?(other)
		Friendship.between(self, other).mutual.exists?
	end
	
	private
		def create_remember_token
			self.remember_token = SecureRandom.urlsafe_base64
		end
end
