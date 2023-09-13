class PopulateBypassEmailLogin < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:populate_bypass_email_login'].invoke if AfterParty::TaskRecord.where(version: 20210409131949).empty?
  end
end
