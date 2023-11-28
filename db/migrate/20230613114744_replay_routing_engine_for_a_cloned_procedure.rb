class ReplayRoutingEngineForAClonedProcedure < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:replay_routing_engine_for_a_cloned_procedure'].invoke if AfterParty::TaskRecord.where(version: 20230613114744).empty?
  end
end
