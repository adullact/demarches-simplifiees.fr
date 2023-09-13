class FixProcedurePresentationWithDeposeSince < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_procedure_presentation_with_depose_since'].invoke if AfterParty::TaskRecord.where(version: 20220614053743).empty?
  end
end
