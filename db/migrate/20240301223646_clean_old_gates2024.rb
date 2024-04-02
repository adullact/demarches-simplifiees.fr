class CleanOldGates2024 < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:clean_old_gates2024'].invoke if AfterParty::TaskRecord.where(version: 20240301223646).empty?
  end
end
