class FixDossierTransferWithUppercase < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_dossier_transfer_with_uppercase'].invoke if AfterParty::TaskRecord.where(version: 20230131132616).empty?
  end
end
