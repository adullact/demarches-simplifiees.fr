class UpdateProcedureRoutingEnabled < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:update_procedure_routing_enabled'].invoke if AfterParty::TaskRecord.where(version: 20221026074507).empty?
  end
end
