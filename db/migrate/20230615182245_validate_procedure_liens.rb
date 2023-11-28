class ValidateProcedureLiens < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:validate_procedure_liens'].invoke if AfterParty::TaskRecord.where(version: 20230615182245).empty?
  end
end
