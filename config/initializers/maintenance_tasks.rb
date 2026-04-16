module MaintenanceTasks
  module SynchronousRunner
    # Run a task immediately, blocking until the underlying job ends.
    # @see MaintenanceTasks::SynchronousRunner.run
    def run_sync(name:, csv_file: nil, arguments: {}, run_model: Run, metadata: nil)
      original_max_job_runtime = JobIteration.max_job_runtime
      JobIteration.max_job_runtime = 1.month

      run = run_model.new(task_name: name, arguments: arguments, metadata: metadata)
      if csv_file
        run.csv_file.attach(csv_file)
        run.csv_file.filename = filename(name)
      end
      job = instantiate_job(run)
      run.job_id = job.job_id
      yield run if block_given?
      run.enqueued!
      job.perform_now # execute the job immediately

      if run.errored?
        raise "Job execution failed: #{run.error_class} #{run.error_message}\n#{run.backtrace.join("\n")}"
      end
      Task.named(name)
    ensure
      JobIteration.max_job_runtime = original_max_job_runtime
    end
  end

  module TaskExtension
    def takes_arguments?
      attribute_names.any? || collection_builder_strategy.class.name.include?("Csv")
    end
  end
end

Rails.application.config.after_initialize do
  MaintenanceTasks::Runner.extend(MaintenanceTasks::SynchronousRunner)
  MaintenanceTasks::Task.extend(MaintenanceTasks::TaskExtension)
end
