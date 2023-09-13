class FixHiddenByReasonNil < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_hidden_by_reason_nil'].invoke if AfterParty::TaskRecord.where(version: 20220516160033).empty?
  end
end
