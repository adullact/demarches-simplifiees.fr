class MoveTraitementProcessExpiredToProcedure < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:move_traitement_process_expired_to_procedure'].invoke if AfterParty::TaskRecord.where(version: 20211126152402).empty?
  end
end
