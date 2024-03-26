namespace :mirror_disk_to_s3 do
  desc <<~EOD
    rails mirror_disk_to_s3:migrate
    # should be run before fully switching for s3
  EOD
  task migrate: :environment do
    puts "#{ActiveStorage::Blob.where(service_name: :local).count} Blobs to go..."
    ActiveStorage::Blob.where(service_name: :local).find_each do |blob|
      print '.'
      blob.update(service_name: :mirror_local_to_scaleway)
      begin
        blob.mirror_later
      rescue => e
        Sentry.capture_exception(e, extra: { blob_id: blob.id })
        blob.update(service_name: :local)
      end
    end
  end

  # Migrate from local to scaleway
  # We had an integrity error using mirror_later
  # /usr/local/bundle/ruby/3.2.0/gems/activestorage-7.0.7.2/lib/active_storage/downloader.rb:39:in `verify_integrity_of'
  task raw_migrate: :environment do
    configs = Rails.configuration.active_storage.service_configurations
    from_service = ActiveStorage::Service.configure :local, configs
    to_service = ActiveStorage::Service.configure :scaleway, configs

    ActiveStorage::Blob.service = from_service

    ActiveStorage::Blob.where(service_name: :local).find_each do |blob|
      blob.update(service_name: :mirror_local_to_scaleway)
      begin
        blob.open do |tf|
          checksum = blob.checksum
          to_service.upload(blob.key, tf, checksum: checksum)
        end
      rescue
        # rollback
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
    ActiveStorage::Blob.update_all(service_name: :scaleway)
  end
end
