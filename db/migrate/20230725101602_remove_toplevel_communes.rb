class RemoveToplevelCommunes < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:remove_toplevel_communes'].invoke if AfterParty::TaskRecord.where(version: 20230725101602).empty?
  end
end
