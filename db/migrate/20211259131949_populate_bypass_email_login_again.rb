class PopulateBypassEmailLoginAgain < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:populate_bypass_email_login_again'].invoke if AfterParty::TaskRecord.where(version: 20211259131949).empty?
  end
end
