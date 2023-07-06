class FixBackfillProcedureRoutingCriteriaName < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_backfill_procedure_routing_criteria_name'].invoke
  end
end
