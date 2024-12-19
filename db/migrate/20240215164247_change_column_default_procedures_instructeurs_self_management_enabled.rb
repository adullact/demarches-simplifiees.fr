# frozen_string_literal: true

class ChangeColumnDefaultProceduresInstructeursSelfManagementEnabled < ActiveRecord::Migration[7.0]
  def change
    # change_column_default :procedures, :instructeurs_self_management_enabled, false # cause issue with strongparameter
    ActiveRecord::Base.connection.execute("ALTER TABLE procedures ALTER COLUMN instructeurs_self_management_enabled SET DEFAULT FALSE")
  end
end
