namespace :from_party_to_migration do
  desc 'create a migration for each after_party task'
  task create: :environment do
    create_migrations
  end

  def create_migrations
    glob = Rails.root.join('lib', 'tasks', 'deployment', '*.rake')
    Dir.glob(glob).each do |rake_file|
      puts rake_file
      rake_file_basename = File.basename(rake_file, ".rake")
      migration_file = Rails.root.join('db', 'migrate', "#{rake_file_basename}.rb")
      if !File.exist?(migration_file)
        version, rake_file_basename = rake_file_basename.split("_", 2)
        File.write(migration_file, "class #{rake_file_basename.camelize} < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:#{rake_file_basename}'].invoke if AfterParty::TaskRecord.where(version: #{version}).empty?
  end
end
")
      end
    end
  end
end
