class UnrouteClonedProceduresFromDiffentAdmin < ActiveRecord::Migration[6.1]
  def change
    Procedure.reset_column_information
    Rake::Task['after_party:unroute_cloned_procedures_from_diffent_admin'].invoke if AfterParty::TaskRecord.where(version: 20230921132123).empty?
  end
end
