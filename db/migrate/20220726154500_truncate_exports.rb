class TruncateExports < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:truncate_exports'].invoke if AfterParty::TaskRecord.where(version: 20220726154500).empty?
  end
end
