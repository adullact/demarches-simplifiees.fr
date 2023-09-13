class DropDownListOptionsToJSON < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:drop_down_list_options_to_json'].invoke if AfterParty::TaskRecord.where(version: 20200618121241).empty?
  end
end
