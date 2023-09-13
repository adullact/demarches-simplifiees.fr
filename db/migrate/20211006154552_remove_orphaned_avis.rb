class RemoveOrphanedAvis < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:remove_orphaned_avis'].invoke if AfterParty::TaskRecord.where(version: 20211006154552).empty?
  end
end
