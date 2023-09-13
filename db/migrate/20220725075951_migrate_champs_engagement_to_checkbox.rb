class MigrateChampsEngagementToCheckbox < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:migrate_champs_engagement_to_checkbox'].invoke if AfterParty::TaskRecord.where(version: 20220725075951).empty?
  end
end
