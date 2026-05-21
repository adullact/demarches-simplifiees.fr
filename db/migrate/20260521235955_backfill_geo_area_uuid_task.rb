# frozen_string_literal: true

class BackfillGeoAreaUuidTask < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.descendants.each(&:reset_column_information)
    MaintenanceTasks::Runner.run_sync(name: "Maintenance::T20260521BackfillGeoAreaUuidTask")
  end
end
