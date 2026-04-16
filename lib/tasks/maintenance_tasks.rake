# frozen_string_literal: true

namespace :maintenance_tasks do
  IGNORED_VALIDATION_ERRORS = [:arguments, :csv_file]

  # Use with `bin/rails "maintenance_tasks:skip[MyMaintenanceTask]"`
  desc "Skip a maintenance task permanently, so that is doesn't appear in the list of pending tasks."
  task :skip, [:task_name] => :environment do |_task, args|
    task_name = "Maintenance::#{args[:task_name]}"

    run = MaintenanceTasks::Run.find_by(task_name: task_name) || MaintenanceTasks::Run.new(task_name: task_name, arguments: {})
    if run.persisted? && run.active?
      abort("Cannot skip a running task; stop the task first then retry.")
    end
    if run.persisted? && run.cancelled?
      Rails.logger.info("This task has already been cancelled; nothing to do.")
      exit
    end

    run.assign_attributes(status: :cancelled, ended_at: Time.zone.now)

    run.validate
    if run.errors.to_hash.excluding(IGNORED_VALIDATION_ERRORS).present?
      raise StandardError, "Could not skip task #{task_name}: #{run.errors.full_messages.to_sentence}"
    end

    run.save!(validate: false)
    Rails.logger.info("Task #{task_name} skipped permanently.")
  end

  desc "Create a migration for each maintenance task"
  task generate_migrations: :environment do
    glob = Rails.root.join("app", "tasks", "maintenance", "*_task.rb")
    Dir.glob(glob).each do |task_filename|
      next unless File.basename(task_filename).start_with?(/t([0-9]{8})/)

      task_class_name = File.basename(task_filename, ".rb").camelize
      task = MaintenanceTasks::Task.named("Maintenance::#{task_class_name}")

      if task.takes_arguments?
        puts "Skipping migration for #{task_class_name}: the migration takes custom arguments"
        next
      end

      task_timestamp, task_name = task_filename.match(/t([0-9]{8})_?(.*_task).rb/).captures

      # Migrations are ordered at the very end of the day, so that they are run after actual DB migrations dated of the same day
      migration_unique_identifier = "2359" + (Digest::MD5.hexdigest(task_name).to_i(16) % 60).to_s.rjust(2, "0")
      migration_timestamp = task_timestamp + migration_unique_identifier
      migration_filename = Rails.root.join("db", "migrate", "#{migration_timestamp}_#{task_name}.rb")

      if !File.exist?(migration_filename)
        File.write(migration_filename, "# frozen_string_literal: true

class #{task_name.camelize} < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.descendants.each(&:reset_column_information)
    MaintenanceTasks::Runner.run_sync(name: \"Maintenance::#{task_class_name}\")
  end
end
")
        puts "Generated migration for #{task_class_name} at #{migration_filename}"
      end
    end
  end
end
