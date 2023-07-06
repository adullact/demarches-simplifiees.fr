class FixChampsRevisions < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_champs_revisions'].invoke
  end
end
