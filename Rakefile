require 'gemwhisperer'

namespace :db do
  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end
