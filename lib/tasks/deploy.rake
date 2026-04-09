# frozen_string_literal: true

namespace :deploy do
  desc "Enqueue all maintenance tasks that need to run on deploy"
  task maintenance_tasks: :environment do
    tasks = MaintenanceTasks::Task
      .load_all
      .filter { _1.respond_to?(:run_on_deploy?) && _1.run_on_deploy? }

    tasks.each do |task|
      Rails.logger.info { "MaintenanceTask run on deploy #{task.name}" }
      MaintenanceTasks::Runner.run(name: task.name)
    end
  end

  namespace :maintenance_tasks do
    desc "Enqueue all maintenance tasks that need to run on deploy, and wait for completion"
    task wait: [:environment, :maintenance_tasks] do
      while active_runs.any?
        Rails.logger.info { readable_status(active_runs.first) }
        sleep poll_interval
      end
      Rails.logger.info { "All running maintenance tasks finished" }
    end

    def active_runs = MaintenanceTasks::Run.completed.invert_where

    def poll_interval = 2.seconds

    def readable_status(run)
      status = "Currently processing #{run.task_name} (#{run.status})"
      status += ", estimated to finish in #{run.time_to_completion.round(0)}s" if run.time_to_completion
      status
    end
  end
end
