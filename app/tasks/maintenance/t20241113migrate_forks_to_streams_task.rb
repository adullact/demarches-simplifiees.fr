# frozen_string_literal: true

module Maintenance
  class T20241113migrateForksToStreamsTask < MaintenanceTasks::Task
    # Documentation: cette tâche modifie les données pour…

    include RunnableOnDeployConcern
    include StatementsHelpersConcern

    # Local model for running the migration (the forks methods have been removed since)
    class Dossier < ::Dossier
      self.ignored_columns -= [:editing_fork_origin_id.to_s]

      belongs_to :editing_fork_origin, class_name: 'Maintenance::T20241113migrateForksToStreamsTask::Dossier', optional: true
      has_many :editing_forks, -> { where(hidden_by_reason: nil) }, class_name: 'Maintenance::T20241113migrateForksToStreamsTask::Dossier', foreign_key: :editing_fork_origin_id, dependent: :destroy, inverse_of: :editing_fork_origin

      def owner_editing_fork
        find_or_create_editing_fork(user).tap(&:with_champs)
      end

      def find_or_create_editing_fork(user)
        find_editing_fork(user) || clone_fork(user:)
      end

      def find_editing_fork(user, rebase: true)
        fork = editing_forks.find_by(user:)
        fork = fork.with_champs if fork
        fork.rebase! if rebase && fork

        fork
      end

      def clone_fork(user: nil, fork: true)
        dossier_attributes = [:autorisation_donnees, :revision_id]
        dossier_attributes += [:groupe_instructeur_id] if fork
        relationships = [:individual, :etablissement]

        discarded_row_ids = champs_on_main_stream
                              .filter { _1.row? && _1.discarded? }
                              .to_set(&:row_id)
        cloned_champs = champs_on_main_stream
                          .reject { discarded_row_ids.member?(_1.row_id) }
                          .index_by(&:id)
                          .transform_values { [_1, _1.clone] }

        cloned_dossier = deep_clone(only: dossier_attributes, include: relationships) do |original, kopy|
          ClonePiecesJustificativesService.clone_attachments(original, kopy)

          if original.is_a?(Dossier)
            if fork
              kopy.editing_fork_origin = original
            else
              kopy.parent_dossier = original
            end

            kopy.user = user || original.user
            kopy.state = Dossier.states.fetch(:brouillon)
            kopy.champs = cloned_champs.values.map do |(_, champ)|
              champ.dossier = kopy
              champ
            end
          end
        end

        transaction do
          if fork
            cloned_dossier.save!(validate: false)
          else
            cloned_dossier.validate(:champs_public_value)
            cloned_dossier.save!
          end
          cloned_dossier.rebase!
        end

        if fork
          cloned_champs.values.each do |(original, champ)|
            champ.update_columns(created_at: original.created_at, updated_at: original.updated_at)
          end
        end

        cloned_dossier.index_search_terms_later if !fork
        cloned_dossier.reload
      end

      def make_diff(editing_fork)
        origin_champs_index = project_champs_public_all.index_by(&:public_id)
        forked_champs_index = editing_fork.project_champs_public_all.index_by(&:public_id)
        updated_champs_index = editing_fork
          .project_champs_public_all
          .filter { _1.updated_at > editing_fork.created_at }
          .index_by(&:public_id)

        added = forked_champs_index.keys - origin_champs_index.keys
        removed = origin_champs_index.keys - forked_champs_index.keys
        updated = updated_champs_index.keys - added

        {
          added: added.map { forked_champs_index[_1] },
          updated: updated.map { forked_champs_index[_1] },
          removed: removed.map { origin_champs_index[_1] }
        }
      end

      def apply_diff(diff)
        added_row_ids = {}
        diff[:added].each do |champ|
          next if !champ.child?
          next if added_row_ids.key?(champ.row_id)
          added_row_ids[champ.row_id] = revision.parent_of(champ.type_de_champ)
        end

        removed_row_ids = {}
        diff[:removed].each do |champ|
          next if !champ.child?
          next if removed_row_ids.key?(champ.row_id)
          removed_row_ids[champ.row_id] = revision.parent_of(champ.type_de_champ)
        end

        added_champs = diff[:added].filter { _1.persisted? && _1.fillable? }
        updated_champs = diff[:updated].filter { _1.persisted? && _1.fillable? }

        added_champs.each { _1.update_columns(dossier_id: id, stream:) }

        if updated_champs.present?
          champs_index = champs.index_by(&:public_id)
          updated_champs.each do |champ|
            champs_index[champ.public_id]&.destroy!
            champ.update_columns(dossier_id: id, stream:)
          end
        end

        added_row_ids.each do |row_id, repetition_type_de_champ|
          champ_for_update(repetition_type_de_champ, row_id:, updated_by: user.email)
        end
        removed_row_ids.each do |row_id, repetition_type_de_champ|
          champ_for_update(repetition_type_de_champ, row_id:, updated_by: user.email).discard!
        end
      end
    end

    def collection
      Dossier.joins(:editing_fork_origin).where(editing_fork_origin: { state: 'en_construction' })
    end

    def process(fork)
      DossierPreloader.load_one(fork)
      dossier_en_construction = fork.editing_fork_origin
      dossier_en_construction.rebase!
      dossier_en_construction.reload
      DossierPreloader.load_one(dossier_en_construction)
      diff = dossier_en_construction.make_diff(fork)
      dossier_en_construction.send(:with_stream, Champ::USER_BUFFER_STREAM)
      dossier_en_construction.transaction do
        dossier_en_construction.send(:apply_diff, diff)
        fork.reload
        fork.destroy!
      end
    end
  end
end
