class AddDeposeAtToDossiersParty < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:add_depose_at_to_dossiers_party'].invoke if AfterParty::TaskRecord.where(version: 20211124112843).empty?
  end
end
