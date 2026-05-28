# frozen_string_literal: true

require "rails_helper"

module Maintenance
  RSpec.describe T20241202removeUnusedForksTask do
    # Re-open the local migration model to re-add methods that can create forked data
    class Maintenance::T20241202removeUnusedForksTask::Dossier
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
    end

    before(:context) do
      FactoryBot.define do
        factory :migration_dossier, class: Maintenance::T20241202removeUnusedForksTask::Dossier, parent: :dossier do
        end
      end
    end

    describe "#process" do
      subject(:collection) { described_class.collection }
      let(:procedure) { create(:procedure) }
      let(:dossier1) { create(:migration_dossier, :en_construction, procedure:) }
      let(:dossier2) { create(:migration_dossier, :en_instruction, procedure:) }
      let(:dossier3) { create(:migration_dossier, :accepte, procedure:) }

      before do
        dossier1.owner_editing_fork
        dossier2.owner_editing_fork
        dossier3.owner_editing_fork
      end

      it { is_expected.to match_array([dossier2.owner_editing_fork, dossier3.owner_editing_fork]) }
    end
  end
end
