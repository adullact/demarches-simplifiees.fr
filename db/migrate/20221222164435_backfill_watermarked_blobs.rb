class BackfillWatermarkedBlobs < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_watermarked_blobs'].invoke if AfterParty::TaskRecord.where(version: 20221222164435).empty?
  end
end
