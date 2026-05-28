# frozen_string_literal: true

module Maintenance
  class T20241202removeUnusedForksTask < MaintenanceTasks::Task
    # Documentation: Cette tâche supprime les forks laissés après le passage en instruction

    include RunnableOnDeployConcern
    include StatementsHelpersConcern

    # Local model for running the migration (the forks associations have been removed since)
    class Dossier < ::Dossier
      self.ignored_columns -= [:editing_fork_origin_id.to_s]
      belongs_to :editing_fork_origin, class_name: 'Maintenance::T20241202removeUnusedForksTask::Dossier', optional: true
      has_many :editing_forks, -> { where(hidden_by_reason: nil) }, class_name: 'Maintenance::T20241202removeUnusedForksTask::Dossier', foreign_key: :editing_fork_origin_id, dependent: :destroy, inverse_of: :editing_fork_origin
    end

    def collection
      Dossier.joins(:editing_fork_origin).where.not(editing_fork_origin: { state: 'en_construction' })
    end

    def process(dossier)
      dossier.destroy!
    end
  end
end
