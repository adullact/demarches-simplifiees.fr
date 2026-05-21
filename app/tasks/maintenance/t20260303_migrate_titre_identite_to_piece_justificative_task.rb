# frozen_string_literal: true

module Maintenance
  class T20260303MigrateTitreIdentiteToPieceJustificativeTask < MaintenanceTasks::Task
    include RunnableOnDeployConcern
    include StatementsHelpersConcern

    run_on_first_deploy

    # Migration atomique des TypeDeChamp ET Champs de type 'titre_identite'
    # vers 'piece_justificative' avec nature='TITRE_IDENTITE'
    #
    # Pour chaque TypeDeChamp migré, tous les Champs associés (via stable_id)
    # sont également migrés dans la même transaction.
    #
    # Volume estimé:
    # - TypeDeChamp: ~4 272
    # - Champs: ~326 388
    #
    # Durée estimée: ~10-15 minutes
    #
    # Cette migration est idempotente et peut être relancée sans risque.

    def collection
      TypeDeChamp.where(type_champ: 'titre_identite').in_batches
    end

    def process(type_de_champ_batch)
      # Figer les IDs du batch pour éviter le "moving target"
      type_de_champ_ids = type_de_champ_batch.pluck(:id)

      TypeDeChamp.where(id: type_de_champ_ids, type_champ: 'titre_identite').find_each do |type_de_champ|
        # Migration du TypeDeChamp + ses Champs dans une transaction
        ActiveRecord::Base.transaction do
          migrate_type_de_champ(type_de_champ)
          migrate_champs_for_type_de_champ(type_de_champ)
        end
      end
    end

    def count
      with_statement_timeout("15min") do
        TypeDeChamp.where(type_champ: 'titre_identite').count
      end
    end

    private

    def migrate_type_de_champ(type_de_champ)
      # Idempotence: skip si déjà migré
      return if type_de_champ.piece_justificative? && type_de_champ.titre_identite?

      type_de_champ.update_columns(
        type_champ: 'piece_justificative',
        nature: 'TITRE_IDENTITE',
        updated_at: Time.zone.now
      )

      Rails.logger.info(
        "[T20260303MigrateTitreIdentite] Migrated TypeDeChamp #{type_de_champ.id} " \
        "(stable_id: #{type_de_champ.stable_id})"
      )
    end

    def migrate_champs_for_type_de_champ(type_de_champ)
      # Migrer tous les Champs liés à ce TypeDeChamp via stable_id
      champs_to_migrate = Champ.where(
        type: 'Champs::TitreIdentiteChamp',
        stable_id: type_de_champ.stable_id
      )

      count = champs_to_migrate.count

      if count > 0
        # Update en batch pour performance
        champs_to_migrate.update_all(type: 'Champs::PieceJustificativeChamp')

        Rails.logger.info(
          "[T20260303MigrateTitreIdentite] Migrated #{count} Champs for TypeDeChamp #{type_de_champ.id} " \
          "(stable_id: #{type_de_champ.stable_id})"
        )
      end
    end
  end
end
