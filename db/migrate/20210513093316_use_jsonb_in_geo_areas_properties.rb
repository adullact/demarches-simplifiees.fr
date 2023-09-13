class UseJsonbInGeoAreasProperties < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:use_jsonb_in_geo_areas_properties'].invoke if AfterParty::TaskRecord.where(version: 20210513093316).empty?
  end
end
