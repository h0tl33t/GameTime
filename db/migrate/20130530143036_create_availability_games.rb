class CreateAvailabilityGames < ActiveRecord::Migration
  def change
    create_table :availability_games do |t|

      t.timestamps
    end
  end
end
