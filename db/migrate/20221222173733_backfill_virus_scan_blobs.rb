class BackfillVirusScanBlobs < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_virus_scan_blobs'].invoke if AfterParty::TaskRecord.where(version: 20221222173733).empty?
  end
end
