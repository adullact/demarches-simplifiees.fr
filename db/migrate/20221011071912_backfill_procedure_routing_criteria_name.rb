class BackfillProcedureRoutingCriteriaName < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_procedure_routing_criteria_name'].invoke if AfterParty::TaskRecord.where(version: 20221011071912).empty?
  end
end
