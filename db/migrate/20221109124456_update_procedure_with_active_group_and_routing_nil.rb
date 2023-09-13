class UpdateProcedureWithActiveGroupAndRoutingNil < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:update_procedure_with_active_group_and_routing_nil'].invoke if AfterParty::TaskRecord.where(version: 20221109124456).empty?
  end
end
