class AddGameIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :game_id, :integer
  end
end
