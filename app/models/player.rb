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
#

class Player < ActiveRecord::Base
	has_secure_password
	
	before_save {|player| player.email.downcase!}
	before_save :create_remember_token
	
	validates :name, presence: true, length: {maximum: 50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
	validates :alias, presence: true
	validates :password, presence: true, length: {minimum: 6}
	validates :password_confirmation, presence: true
	
	private
		def create_remember_token
			self.remember_token = SecureRandom.urlsafe_base64
		end
end
