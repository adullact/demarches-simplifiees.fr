class RemoveUnusedChamps < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:remove_unused_champs'].invoke if AfterParty::TaskRecord.where(version: 20220705164551).empty?
  end
end
