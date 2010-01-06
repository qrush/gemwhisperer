class RenameInfo < ActiveRecord::Migration
  def self.up
    infos = Whisper.all.map { |w| [w.id, w.info] }

    remove_column :whispers, :info
    add_column :whispers, :info, :text

    infos.each do |id, info|
      w = Whisper.find(id)
      w.info = info
      w.save
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
