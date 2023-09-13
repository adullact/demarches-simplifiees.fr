class CleanupChampsDossierForeignKeys < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:cleanup_champs_dossier_foreign_keys'].invoke if AfterParty::TaskRecord.where(version: 20220914090601).empty?
  end
end
