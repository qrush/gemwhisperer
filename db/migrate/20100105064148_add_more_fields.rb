class AddMoreFields < ActiveRecord::Migration
  def self.up
    add_column :whispers, :url, :string
  end

  def self.down
    remove_column :whispers, :url
  end
end
