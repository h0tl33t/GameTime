class RemoveEncryptedPasswordFromPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :encrypted_password, :string
  end
end
