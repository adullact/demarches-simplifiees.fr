class CleanupEtablissementsDossierForeignKeys < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:cleanup_etablissements_dossier_foreign_keys'].invoke if AfterParty::TaskRecord.where(version: 20220914090631).empty?
  end
end
