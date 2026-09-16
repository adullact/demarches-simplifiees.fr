# frozen_string_literal: true

require "rails_helper"

module Maintenance
  RSpec.describe T20260916stripWhitespaceFromSiretExternalIdTask do
    let(:procedure) { create(:procedure, public_type_de_champs: [{ type: :siret }, { type: :rna }]) }
    let(:dossier) { create(:dossier, procedure:) }
    let(:champ) { dossier.champ_data.find { _1.is_a?(Champs::SiretChamp) } }
    let(:rna) { dossier.champ_data.find { _1.is_a?(Champs::RNAChamp) } }
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

    # What #collection yields: the first id of a range covering both champs.
    def run! = described_class.new.process([champ.id, rna.id].min)

    # update_all leaves updated_at alone, and xmin stays put inside the example's
    # transaction: only the physical location says whether the UPDATE rewrote a
    # row it had no reason to touch.
    def row_version(record) = record.class.base_class.where(id: record.id).pick(Arel.sql("ctid::text"))

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

      # A range holds every champ type, so the scope is the only thing standing
      # between the UPDATE and the other champs it sweeps over.
      it "leaves the other champ types alone" do
        plant('W99 1234567', on: rna)

        expect { run! }.not_to change { rna.reload.external_id }
      end

      it "does not rewrite the rows that are already clean" do
        plant('30613890001294')

        expect { run! }.not_to change { row_version(champ) }
      end
    end

    describe "#collection" do
      subject(:ranges) { described_class.new.collection }

      it "covers every champ, whatever the gaps in the id sequence" do
        expect(ranges.any? { (_1...(_1 + described_class::RANGE_SIZE)).cover?(champ.id) }).to be(true)
      end

      it "starts on the first champ and runs past the last" do
        expect(ranges.first).to eq(ChampData.minimum(:id))
        expect(ranges.last + described_class::RANGE_SIZE).to be > ChampData.maximum(:id)
      end
    end
  end
end
