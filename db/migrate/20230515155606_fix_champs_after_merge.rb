class FixChampsAfterMerge < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_champs_after_merge'].invoke
  end
end
