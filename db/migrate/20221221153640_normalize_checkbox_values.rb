class NormalizeCheckboxValues < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:normalize_checkbox_values'].invoke if AfterParty::TaskRecord.where(version: 20221221153640).empty?
  end
end
