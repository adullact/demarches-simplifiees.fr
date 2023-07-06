class FixInstructeursSelfManagementForRoutedProcedures < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['after_party:fix_instructeurs_self_management_for_routed_procedures'].invoke
  end
end
