class AddIndexToAvailabilitiesGames < ActiveRecord::Migration
  def change
	add_index :availabilities_games, [:availability_id, :game_id]
  end
end
