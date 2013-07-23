class SetDefaultGameIdForPlayer < ActiveRecord::Migration
  def change
		change_column :players, :game_id, :integer, :default => 1
		Player.update_all({game_id: 1},{game_id: nil})
  end
end
