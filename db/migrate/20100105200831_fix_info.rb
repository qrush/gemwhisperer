class FixInfo < ActiveRecord::Migration
  def self.up
    rename_column :whispers, :description, :info
  end

  def self.down
    rename_column :whispers, :info, :description
  end
end
