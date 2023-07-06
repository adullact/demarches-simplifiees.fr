class PopulateZonesWithTchapHs < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:populate_zones_with_tchap_hs'].invoke
  end
end
