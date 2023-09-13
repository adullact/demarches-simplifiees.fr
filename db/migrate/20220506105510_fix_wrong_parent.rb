class FixWrongParent < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_wrong_parent'].invoke if AfterParty::TaskRecord.where(version: 20220506105510).empty?
  end
end
