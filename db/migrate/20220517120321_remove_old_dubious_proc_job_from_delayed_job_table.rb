class RemoveOldDubiousProcJobFromDelayedJobTable < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:remove_old_dubious_proc_job_from_delayed_job_table'].invoke if AfterParty::TaskRecord.where(version: 20220517120321).empty?
  end
end
