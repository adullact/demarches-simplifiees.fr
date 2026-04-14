# frozen_string_literal: true

module Maintenance
  class T20250130MigrateExistingProcedurePathsTask < MaintenanceTasks::Task
    include RunnableOnDeployConcern

    run_on_first_deploy

    # Local model, for allowing access to the now-ignored `path` column
    class Procedure < ::Procedure
      self.ignored_columns -= [:path.to_s]
    end

    def collection
      Procedure.all
    end

    def process(element)
      element.ensure_path_exists
      element.save!(validate: false)

      if element.publiee?
        element.procedure_paths << ProcedurePath.find_or_create_by(path: element[:path])
      else
        if !Procedure.publiees.exists?(path: element[:path]) # the path is not used by another published procedure
          element.procedure_paths << ProcedurePath.find_or_create_by(path: element[:path])
        end
      end
      element.save!(validate: false)
    end
  end
end
