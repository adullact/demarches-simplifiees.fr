# frozen_string_literal: true

class MigrateExistingProcedurePathsTask < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.descendants.each(&:reset_column_information)
    MaintenanceTasks::Runner.run_sync(name: "Maintenance::T20250130MigrateExistingProcedurePathsTask")
  end
end
