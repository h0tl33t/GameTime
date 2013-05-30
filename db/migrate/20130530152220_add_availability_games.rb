class AddAvailabilityGames < ActiveRecord::Migration
  def change
	create_table :availabilities_games, :id => false do |t|
		t.references :game
		t.references :availability
	end
  end
end
