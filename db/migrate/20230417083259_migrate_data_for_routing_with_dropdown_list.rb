class MigrateDataForRoutingWithDropdownList < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:migrate_data_for_routing_with_dropdown_list'].invoke
  end
end
