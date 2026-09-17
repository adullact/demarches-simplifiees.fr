# frozen_string_literal: true

class PurgeEmptyAttachmentsTask < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    return if ENV["ASYNC_MAINTENANCE_TASKS"].present?

    ActiveRecord::Base.descendants.each(&:reset_column_information)
    MaintenanceTasks::Runner.run_sync(name: "Maintenance::T20260728PurgeEmptyAttachmentsTask")
  end
end
