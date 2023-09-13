class MigrateTypeDeChampParent < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:migrate_type_de_champ_parent'].invoke if AfterParty::TaskRecord.where(version: 20210630101910).empty?
  end
end
