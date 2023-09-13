class SetDefaultForProcedurePreviewOnDossiers < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:set_default_for_procedure_preview_on_dossiers'].invoke if AfterParty::TaskRecord.where(version: 20220427195148).empty?
  end
end
