class RemoveInvalidGeometries < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:remove_invalid_geometries'].invoke if AfterParty::TaskRecord.where(version: 20210310170650).empty?
  end
end
