class FixProcedurePresentationWithUpdatedSince < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_procedure_presentation_with_updated_since'].invoke if AfterParty::TaskRecord.where(version: 20220614053744).empty?
  end
end
