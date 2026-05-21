# frozen_string_literal: true

class BackfillDossierNotificationForDossierDeposeTask < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    MaintenanceTasks::Runner.run_sync(name: "Maintenance::T20250410backfillDossierNotificationForDossierDeposeTask")
  end
end
