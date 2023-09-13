class CleanOrphanedTargetedUserLinks < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:clean_orphaned_targeted_user_links'].invoke if AfterParty::TaskRecord.where(version: 20221004112700).empty?
  end
end
