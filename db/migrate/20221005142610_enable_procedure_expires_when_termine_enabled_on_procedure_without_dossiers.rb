class EnableProcedureExpiresWhenTermineEnabledOnProcedureWithoutDossiers < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:enable_procedure_expires_when_termine_enabled_on_procedure_without_dossiers'].invoke if AfterParty::TaskRecord.where(version: 20221005142610).empty?
  end
end
