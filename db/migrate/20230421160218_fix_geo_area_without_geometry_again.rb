class FixGeoAreaWithoutGeometryAgain < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_geo_area_without_geometry_again'].invoke
  end
end
