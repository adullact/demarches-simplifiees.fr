class RemoveUnusedColumnOnTypeDeChamps < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:remove_unused_column_on_type_de_champs'].invoke if AfterParty::TaskRecord.where(version: 20220822135410).empty?
  end
end
