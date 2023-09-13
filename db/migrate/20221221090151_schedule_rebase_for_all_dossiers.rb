class ScheduleRebaseForAllDossiers < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:schedule_rebase_for_all_dossiers'].invoke if AfterParty::TaskRecord.where(version: 20221221090151).empty?
  end
end
