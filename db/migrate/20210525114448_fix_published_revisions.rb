class FixPublishedRevisions < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_published_revisions'].invoke if AfterParty::TaskRecord.where(version: 20210525114448).empty?
  end
end
