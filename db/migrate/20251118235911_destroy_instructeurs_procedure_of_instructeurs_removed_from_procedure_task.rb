# frozen_string_literal: true

class DestroyInstructeursProcedureOfInstructeursRemovedFromProcedureTask < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.descendants.each(&:reset_column_information)
    MaintenanceTasks::Runner.run_sync(name: "Maintenance::T20251118destroyInstructeursProcedureOfInstructeursRemovedFromProcedureTask")
  end
end
