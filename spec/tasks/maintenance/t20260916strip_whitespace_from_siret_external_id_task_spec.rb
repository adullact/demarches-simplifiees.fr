# frozen_string_literal: true

require "rails_helper"

module Maintenance
  RSpec.describe T20260916stripWhitespaceFromSiretExternalIdTask do
    let(:procedure) { create(:procedure, public_type_de_champs: [{ type: :siret }, { type: :rna }]) }
    let(:dossier) { create(:dossier, procedure:) }
    let(:champ) { dossier.champ_data.find { _1.is_a?(Champs::SiretChamp) } }
    let(:long_ago) { Time.zone.local(2024, 1, 1) }

    # `normalizes` runs on assignment, so the only way to plant the legacy value
    # is the raw expression T20251029backfillChampSiretExternalStateTask used.
    # The timestamps go back with it: at second precision a touch during the
    # example would otherwise be indistinguishable from no touch at all.
    def plant(external_id, on: champ)
      on.class.base_class.where(id: on.id).update_all(
        ApplicationRecord.sanitize_sql_array(["external_id = ?, updated_at = ?", external_id, long_ago])
      )
      Dossier.where(id: dossier.id).update_all(updated_at: long_ago)
    end

    # What #collection yields: a batch is always scoped to the siret champs.
    def run! = described_class.new.process(Champs::SiretChamp.where(dossier_id: dossier.id))

    describe "#process" do
      it "strips the spaces the legacy backfill copied in" do
        plant('306 138 900 01294')

        expect { run! }.to change { champ.reload.external_id }.to('30613890001294')
      end

      it "does not date the champ, whose updated_at the instructeur reads" do
        plant('306 138 900 01294')

        expect { run! }.not_to change { champ.reload.updated_at }
      end

      it "does not date the dossier, which sorts the instructeur list" do
        plant('306 138 900 01294')

        expect { run! }.not_to change { dossier.reload.updated_at }
      end

      it "runs again without rewriting an already clean champ" do
        plant('306 138 900 01294')
        run!

        expect { run! }.not_to change { champ.reload.updated_at }
      end
    end

    describe "#collection" do
      def collected?(record) = described_class.new.collection.any? { _1.ids.include?(record.id) }

      it "batches over the siret champs" do
        plant('306 138 900 01294')

        expect(collected?(champ)).to be(true)
      end

      it "leaves the other champ types out, spaces or not" do
        rna = dossier.champ_data.find { _1.is_a?(Champs::RNAChamp) }
        plant('W99 1234567', on: rna)

        expect(collected?(rna)).to be(false)
        expect(rna.reload.external_id).to eq('W99 1234567')
      end
    end
  end
end
