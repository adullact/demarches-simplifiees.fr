class FixGeoAreaMissingSource < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_geo_area_missing_source'].invoke if AfterParty::TaskRecord.where(version: 20221221115241).empty?
  end
end
