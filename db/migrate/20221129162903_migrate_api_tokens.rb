class MigrateAPITokens < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:migrate_api_tokens'].invoke if AfterParty::TaskRecord.where(version: 20221129162903).empty?
  end
end
