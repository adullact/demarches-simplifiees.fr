# frozen_string_literal: true

require "rails_helper"

module Maintenance
  RSpec.describe T20250526NullifyRowIdTask do
    describe "#process" do
      subject(:process) { described_class.process(Dossier.select(:id).where(id: dossier.id).in_batches.first) }
      let(:procedure) { create(:procedure, types_de_champ_public: [{}, { type: :repetition, children: [{ type: :text }] }]) }
      let(:dossier) { create(:dossier, :with_populated_champs, procedure:) }
      let(:champs_with_null_row_id) { dossier.champs.where(row_id: [nil, Champ::NULL_ROW_ID]) }

      before do
        dossier.champs.where(row_id: nil).update_all(row_id: Champ::NULL_ROW_ID)
      end

      def null_row_id_counts
        champs_with_null_row_id.pluck(:row_id)
          .partition(&:nil?)
          .map(&:size)
      end

      it 'nullify row_id' do
        expect { process }. to change { null_row_id_counts }.from([0, 1]).to([1, 0])
      end

      context 'deal with conflicts' do
        let(:with_null_row_id) { dossier.champs.where(row_id: Champ::NULL_ROW_ID).first }
        let(:with_nil_row_id) { dossier.champs.create(with_null_row_id.attributes.merge(row_id: nil, id: nil)) }

        context 'when the champ with row_id: nil has been updated last' do
          before { [with_null_row_id, with_nil_row_id].each(&:touch) }

          it 'destroys the NULL_ROW_ID champ' do
            expect { process }. to change { Champ.where(id: with_null_row_id).to_a }.from([with_null_row_id]).to([])
          end

          it 'nullify row_id' do
            expect { process }. to change { null_row_id_counts }.from([1, 1]).to([1, 0])
          end
        end

        context 'when the champ with row_id: NULL_ROW_ID has been updated last' do
          before { [with_nil_row_id, with_null_row_id].each(&:touch) }

          it 'destroys the row_id: nil champ' do
            expect { process }. to change { Champ.where(id: with_nil_row_id).to_a }.from([with_nil_row_id]).to([])
          end

          it 'nullify row_id' do
            expect { process }. to change { null_row_id_counts }.from([1, 1]).to([1, 0])
          end
        end
      end
    end
  end
end
