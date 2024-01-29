namespace :mirror_disk_to_s3 do
  desc <<~EOD
    rails mirror_disk_to_s3:migrate
    # should be run before fully switching for s3
  EOD
  task migrate: :environment do
    puts "#{ActiveStorage::Blob.where(service_name: :local).count} Blobs to go..."
    ActiveStorage::Blob.where(service_name: :local).find_each do |blob|
      print '.'
      blob.update(service_name: :mirror_local_to_amazon)
      begin
        blob.mirror_later
      rescue => e
        Sentry.capture_exception(e, extra: { blob_id: blob.id })
        blob.update(service_name: :local)
      end
    end
  end

  desc <<~EOD
    rails mirror_disk_to_s3:migrate
    rails 'mirror_disk_to_s3:switch_for_s3'
    # should be run while fully switching for s3
  EOD
  task switch_for_s3: :environment do
    ActiveStorage::Blob.update_all(service_name: :amazon)
  end
end
