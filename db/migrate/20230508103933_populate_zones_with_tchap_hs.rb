class PopulateZonesWithTchapHs < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:populate_zones_with_tchap_hs'].invoke if AfterParty::TaskRecord.where(version: 20230322172910).empty?
  end
end
