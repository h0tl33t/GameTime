class AddIndexToPlayersEmail < ActiveRecord::Migration
  def change
	add_index :players, :email, unique: true
  end
end
