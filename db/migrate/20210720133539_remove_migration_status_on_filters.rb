class RemoveMigrationStatusOnFilters < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:remove_migration_status_on_filters'].invoke if AfterParty::TaskRecord.where(version: 20210720133539).empty?
  end
end
