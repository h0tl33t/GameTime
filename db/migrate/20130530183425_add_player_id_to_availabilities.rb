class AddPlayerIdToAvailabilities < ActiveRecord::Migration
  def change
    add_column :availabilities, :player_id, :integer
  end
end
