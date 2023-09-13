class CleanOldGates < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:clean_old_gates'].invoke if AfterParty::TaskRecord.where(version: 20221128205201).empty?
  end
end
