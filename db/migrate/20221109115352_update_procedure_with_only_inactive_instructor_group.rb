class UpdateProcedureWithOnlyInactiveInstructorGroup < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:update_procedure_with_only_inactive_instructor_group'].invoke if AfterParty::TaskRecord.where(version: 20221109115352).empty?
  end
end
