class CleanupAttachments < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:cleanup_attachments'].invoke if AfterParty::TaskRecord.where(version: 20220728062218).empty?
  end
end
