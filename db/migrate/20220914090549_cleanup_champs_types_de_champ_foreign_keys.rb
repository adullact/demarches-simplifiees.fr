class CleanupChampsTypesDeChampForeignKeys < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:cleanup_champs_types_de_champ_foreign_keys'].invoke if AfterParty::TaskRecord.where(version: 20220914090549).empty?
  end
end
