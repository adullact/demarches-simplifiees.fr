class NormalizeDatetimeValues < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:normalize_datetime_values'].invoke if AfterParty::TaskRecord.where(version: 20221221170137).empty?
  end
end
