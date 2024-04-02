class RemoveOrphanDossierOperationLogs < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:remove_orphan_dossier_operation_logs'].invoke if AfterParty::TaskRecord.where(version: 20231011144554).empty?
  end
end
