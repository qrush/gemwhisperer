class AddEvenMore < ActiveRecord::Migration
  def self.up
    add_column :whispers, :description, :string
  end

  def self.down
    remove_column :whispers, :description
  end
end
