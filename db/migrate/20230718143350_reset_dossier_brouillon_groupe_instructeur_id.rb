class ResetDossierBrouillonGroupeInstructeurId < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:reset_dossier_brouillon_groupe_instructeur_id'].invoke if AfterParty::TaskRecord.where(version: 20230718143350).empty?
  end
end
