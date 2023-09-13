class FixGeoAreasGeometry < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_geo_areas_geometry'].invoke if AfterParty::TaskRecord.where(version: 20200813111957).empty?
  end
end
