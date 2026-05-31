# frozen_string_literal: true

module Maintenance
  class T20250526NullifyRowIdTask < MaintenanceTasks::Task
    # Documentation: cette tâche modifie les données pour…

    include RunnableOnDeployConcern
    include StatementsHelpersConcern

    # Uncomment only if this task MUST run imperatively on its first deployment.
    # If possible, leave commented for manual execution later.
    # run_on_first_deploy

    def collection
      Dossier.select(:id).in_batches(of: 100)
    end

    def process(dossiers_batch)
      Champ
        .where(dossier_id: dossiers_batch.map(&:id))
        .where(row_id: [nil, Champ::NULL_ROW_ID])
        .pluck(:row_id, :stream, :stable_id, :id, :updated_at, :dossier_id)
        .group_by { |(_row_id, _stream, _stable_id, _id, _updated_at, dossier_id)| dossier_id }
        .each do |dossier_id, champs|
          process_dossier(dossier_id, champs)
        end
    end

    def process_dossier(dossier_id, champs)
      with_nil_row_id, with_null_row_id = champs
        .partition { _1.first == nil }
        .map { _1.index_by { |(_, stream, stable_id)| [stream, stable_id] } }

      to_destroy_ids = []
      to_nullify_ids = []

      with_null_row_id.values.each do |(_, stream, stable_id, id, updated_at)|
        if with_nil_row_id[[stream, stable_id]].present?
          with_nil_id, with_nil_updated_at = with_nil_row_id[[stream, stable_id]].then { |(_row_id, _stream, _stable_id, id, updated_at)| [id, updated_at] }
          if with_nil_updated_at > updated_at
            to_destroy_ids << id
          else
            to_destroy_ids << with_nil_id
            to_nullify_ids << id
          end
        else
          to_nullify_ids << id
        end
      end

      Dossier.no_touching do
        Champ.where(dossier_id:).where(id: to_destroy_ids).destroy_all unless to_destroy_ids.empty?
        Champ.where(dossier_id:).where(id: to_nullify_ids).update_all(row_id: nil) unless to_nullify_ids.empty?
      end
    end

    def count
      with_statement_timeout("5min") do
        collection.count
      end
    end
  end
end
