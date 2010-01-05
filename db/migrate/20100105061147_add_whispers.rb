class AddWhispers < ActiveRecord::Migration
  def self.up
    create_table :whispers do |t|
      t.string :name
      t.string :version
      t.timestamps
    end
  end

  def self.down
    drop_table :whispers
  end
end
