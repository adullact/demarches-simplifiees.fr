# frozen_string_literal: true
#
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
end
