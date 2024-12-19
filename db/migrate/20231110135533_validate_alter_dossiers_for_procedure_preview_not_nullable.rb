# frozen_string_literal: true

class ValidateAlterDossiersForProcedurePreviewNotNullable < ActiveRecord::Migration[7.0]
  def change
    validate_check_constraint :dossiers, name: "dossiers_for_procedure_preview_null"
    # change_column_null(:dossiers, :for_procedure_preview, false, false) # cause issue with strongparameter
    ActiveRecord::Base.connection.execute("UPDATE dossiers SET for_procedure_preview=FALSE WHERE for_procedure_preview IS NULL")
    ActiveRecord::Base.connection.execute("ALTER TABLE dossiers ALTER COLUMN for_procedure_preview SET NOT NULL")
    remove_check_constraint :dossiers, name: "dossiers_for_procedure_preview_null"
  end
end
