class FixDossierEtablissement < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_dossier_etablissement'].invoke if AfterParty::TaskRecord.where(version: 20200528124044).empty?
  end
end
