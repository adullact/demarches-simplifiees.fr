class BackfillDossierCorrectionReason < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_dossier_correction_reason'].invoke if AfterParty::TaskRecord.where(version: 20230712095348).empty?
  end
end
