class DropAvailabilityGames < ActiveRecord::Migration
  def change
	drop_table :availability_games
  end
end
