class BackfillRevisionsPublishedAt < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:backfill_revisions_published_at'].invoke if AfterParty::TaskRecord.where(version: 20230209093144).empty?
  end
end
