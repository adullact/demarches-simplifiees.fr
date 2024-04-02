class BackfillProcedureInstructeursSelfManagementEnabled < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_procedure_instructeurs_self_management_enabled'].invoke if AfterParty::TaskRecord.where(version: 20240215164807).empty?
  end
end
