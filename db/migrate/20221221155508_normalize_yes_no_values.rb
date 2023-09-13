class NormalizeYesNoValues < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:normalize_yes_no_values'].invoke if AfterParty::TaskRecord.where(version: 20221221155508).empty?
  end
end
