class RecleanAttachments < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:reclean_attachments'].invoke if AfterParty::TaskRecord.where(version: 20230216135218).empty?
  end
end
