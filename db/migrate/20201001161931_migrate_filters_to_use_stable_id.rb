class MigrateFiltersToUseStableId < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:migrate_filters_to_use_stable_id'].invoke if AfterParty::TaskRecord.where(version: 20201001161931).empty?
  end
end
