class MigrateRevisions < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:migrate_revisions'].invoke if AfterParty::TaskRecord.where(version: 20200625113026).empty?
  end
end
