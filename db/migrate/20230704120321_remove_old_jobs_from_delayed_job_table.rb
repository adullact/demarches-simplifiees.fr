class RemoveOldJobsFromDelayedJobTable < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:remove_old_jobs_from_delayed_job_table'].invoke
  end
end
