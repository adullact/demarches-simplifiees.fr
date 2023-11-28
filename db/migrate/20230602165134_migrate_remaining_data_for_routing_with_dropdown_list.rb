class MigrateRemainingDataForRoutingWithDropdownList < ActiveRecord::Migration[6.1]
  def change
    Procedure.reset_column_information
    Rake::Task['after_party:migrate_remaining_data_for_routing_with_dropdown_list'].invoke if AfterParty::TaskRecord.where(version: 20230602165134).empty?
  end
end
