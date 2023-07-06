class FixClonedPublishedRevisions < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_cloned_published_revisions'].invoke
  end
end
