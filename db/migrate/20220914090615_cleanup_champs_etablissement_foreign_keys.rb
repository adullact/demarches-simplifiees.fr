class CleanupChampsEtablissementForeignKeys < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:cleanup_champs_etablissement_foreign_keys'].invoke if AfterParty::TaskRecord.where(version: 20220914090615).empty?
  end
end
