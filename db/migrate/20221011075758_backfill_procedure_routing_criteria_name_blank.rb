class BackfillProcedureRoutingCriteriaNameBlank < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_procedure_routing_criteria_name_blank'].invoke if AfterParty::TaskRecord.where(version: 20221011075758).empty?
  end
end
