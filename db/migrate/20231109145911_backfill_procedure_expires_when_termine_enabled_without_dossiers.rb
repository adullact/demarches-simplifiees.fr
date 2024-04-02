class BackfillProcedureExpiresWhenTermineEnabledWithoutDossiers < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_procedure_expires_when_termine_enabled_without_dossiers'].invoke if AfterParty::TaskRecord.where(version: 20231109145911).empty?
  end
end
