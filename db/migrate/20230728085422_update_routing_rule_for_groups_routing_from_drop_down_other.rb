class UpdateRoutingRuleForGroupsRoutingFromDropDownOther < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:update_routing_rule_for_groups_routing_from_drop_down_other'].invoke if AfterParty::TaskRecord.where(version: 20230728085422).empty?
  end
end
