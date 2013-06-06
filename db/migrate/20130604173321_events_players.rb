class EventsPlayers < ActiveRecord::Migration
  def change
	create_table :events_players, :id => false do |t|
		t.references :event
		t.references :player
	end
  end
end
