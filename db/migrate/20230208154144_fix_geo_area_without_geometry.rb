class FixGeoAreaWithoutGeometry < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_geo_area_without_geometry'].invoke if AfterParty::TaskRecord.where(version: 20230208154144).empty?
  end
end
