# frozen_string_literal: true

module Maintenance
  class T20241216removeNonUniqueChampsTask < MaintenanceTasks::Task
    # Documentation: cette tâche supprime les champs en double dans un dossier

    include RunnableOnDeployConcern
    include StatementsHelpersConcern

    collection_batch_size(1000)

    def collection
      Dossier.all.select(:id)
    end

    def process(dossier)
      rowless_champs = dossier.champs
        .where(row_id: [Champ::NULL_ROW_ID, nil])
        .order(id: :desc)
        .select(:id, :stream, :stable_id, :row_id)

      duplicated_champ_ids = rowless_champs
        .group_by { "#{_1.stream}-#{_1.public_id}" }
        .values
        .flat_map { _1[1..].map(&:id) }
      nil_row_champ_ids = rowless_champs.filter { _1[:row_id].nil? }.map(&:id)

      Dossier.transaction do
        if duplicated_champ_ids.present?
          Dossier.no_touching { dossier.champs.where(id: duplicated_champ_ids).destroy_all }
        end
        if nil_row_champ_ids.present?
          dossier.champs.where(id: nil_row_champ_ids).update_all(row_id: Champ::NULL_ROW_ID)
        end
      end
    end
  end
end
