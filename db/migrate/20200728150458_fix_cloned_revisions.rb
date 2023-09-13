class FixClonedRevisions < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_cloned_revisions'].invoke if AfterParty::TaskRecord.where(version: 20200728150458).empty?
  end
end
