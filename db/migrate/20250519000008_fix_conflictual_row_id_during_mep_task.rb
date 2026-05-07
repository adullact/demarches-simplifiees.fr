# frozen_string_literal: true

class FixConflictualRowIdDuringMepTask < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    MaintenanceTasks::Runner.run_sync(name: "Maintenance::T20250605fixConflictualRowIdDuringMepTask")
  end
end
