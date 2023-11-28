class DeleteOptionalChampFeatureFlag < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:delete_optional_champ_feature_flag'].invoke if AfterParty::TaskRecord.where(version: 20231003123111).empty?
  end
end
