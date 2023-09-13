class DestroyDossierTransferWithoutEmail < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:destroy_dossier_transfer_without_email'].invoke if AfterParty::TaskRecord.where(version: 20220802133502).empty?
  end
end
