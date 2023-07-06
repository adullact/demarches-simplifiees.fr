class FixAgainHiddenByReasonNil < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_again_hidden_by_reason_nil'].invoke
  end
end
