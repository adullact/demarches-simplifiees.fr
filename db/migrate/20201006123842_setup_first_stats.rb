class SetupFirstStats < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:setup_first_stats'].invoke if AfterParty::TaskRecord.where(version: 20201006123842).empty?
  end
end
