class PopulateZones < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:populate_zones'].invoke if AfterParty::TaskRecord.where(version: 20220922151100).empty?
  end
end
