# frozen_string_literal: true

class FixIndividualGenderTask < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.descendants.each(&:reset_column_information)
    MaintenanceTasks::Runner.run_sync(name: "Maintenance::T20250318FixIndividualGenderTask")
  end
end
