class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :name
      t.string :platform
      t.integer :players_required

      t.timestamps
    end
  end
end
