class FillMissingDateOfFC < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fill_missing_date_of_fc'].invoke if AfterParty::TaskRecord.where(version: 20210412093054).empty?
  end
end
