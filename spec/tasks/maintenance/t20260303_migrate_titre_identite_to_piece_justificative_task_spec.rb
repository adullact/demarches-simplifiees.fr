# frozen_string_literal: true

require "rails_helper"

module Maintenance
  RSpec.describe T20260303MigrateTitreIdentiteToPieceJustificativeTask do
    before do
      stub_const("TypesDeChamp::TitreIdentiteTypeDeChamp", Class.new(TypesDeChamp::TypeDeChampBase))
      stub_const("Champs::TitreIdentiteChamp", Class.new(Champ))

      type_champ_enum = TypeDeChamp.attribute_types["type_champ"]
      allow(type_champ_enum).to receive(:mapping) do
        type_champ_enum.instance_variable_get(:@mapping).merge(titre_identite: 'titre_identite')
      end
    end

    describe "#collection" do
      subject(:collection) { described_class.new.collection }

      let!(:procedure_with_ti) do
        create(:procedure).tap do |p|
          revision = p.active_revision
          revision.revision_types_de_champ.build(type_de_champ: build(:type_de_champ, type_champ: "titre_identite", libelle: "CNI"), position: 1)
          revision.revision_types_de_champ.build(type_de_champ: build(:type_de_champ, type_champ: "titre_identite", libelle: "Passeport"), position: 2)
          revision.save!
        end
      end

      let!(:procedure_with_pj) do
        create(:procedure, types_de_champ_public: [
          { type: :piece_justificative, libelle: "Justificatif" },
        ])
      end

      it "returns only titre_identite TypeDeChamp" do
        # in_batches returns a BatchEnumerator, so we need to flat_map to get actual records
        ids = collection.flat_map { |batch| batch.pluck(:id) }

        tdc_ti_ids = procedure_with_ti.active_revision.types_de_champ_public.pluck(:id)
        tdc_pj_ids = procedure_with_pj.active_revision.types_de_champ_public.pluck(:id)

        expect(ids).to include(*tdc_ti_ids)
        expect(ids).not_to include(*tdc_pj_ids)
      end
    end

    describe "#process" do
      let(:procedure) do
        create(:procedure, :published).tap do |p|
          revision = p.active_revision
          revision.revision_types_de_champ.build(type_de_champ: build(:type_de_champ, type_champ: "titre_identite", libelle: "CNI"), position: 1)
          revision.revision_types_de_champ.build(type_de_champ: build(:type_de_champ, type_champ: "titre_identite", libelle: "Passeport"), position: 2)
          revision.save!
        end
      end

      let!(:dossier_1) { create(:dossier, procedure: procedure) }
      let!(:dossier_2) { create(:dossier, procedure: procedure) }

      let(:tdc_1) { procedure.active_revision.types_de_champ_public.first }
      let(:tdc_2) { procedure.active_revision.types_de_champ_public.second }

      it "migrates TypeDeChamp to piece_justificative with nature titre_identite" do
        batch = TypeDeChamp.where(id: [tdc_1.id, tdc_2.id])
        described_class.new.process(batch)

        expect(tdc_1.reload.type_champ).to eq('piece_justificative')
        expect(tdc_1.reload.nature).to eq('titre_identite')

        expect(tdc_2.reload.type_champ).to eq('piece_justificative')
        expect(tdc_2.reload.nature).to eq('titre_identite')
      end

      it "migrates all associated Champs for each TypeDeChamp" do
        # Vérifier l'état initial
        champs_ti = Champ.where(type: 'Champs::TitreIdentiteChamp', stable_id: tdc_1.stable_id)
        expect(champs_ti.count).to eq(2) # Un champ par dossier

        batch = TypeDeChamp.where(id: tdc_1.id)
        described_class.new.process(batch)

        # Vérifier que tous les Champs ont été migrés
        champs_ti.each do |champ|
          migrated_champ = Champ.find(champ.id)
          expect(migrated_champ.type).to eq('Champs::PieceJustificativeChamp')
        end
      end

      it "preserves champ data and associations during migration" do
        champ_ti = dossier_1.champs.find { |c| c.is_a?(Champs::TitreIdentiteChamp) }
        original_id = champ_ti.id
        original_dossier_id = champ_ti.dossier_id
        original_stable_id = champ_ti.stable_id
        original_type_de_champ_id = champ_ti.type_de_champ.id

        batch = TypeDeChamp.where(id: original_type_de_champ_id)
        described_class.new.process(batch)

        # Recharger avec Champ.find car le type a changé
        champ_migrated = Champ.find(original_id)
        expect(champ_migrated.type).to eq('Champs::PieceJustificativeChamp')
        expect(champ_migrated.dossier_id).to eq(original_dossier_id)
        expect(champ_migrated.stable_id).to eq(original_stable_id)

        # Vérifier que le TypeDeChamp est aussi migré
        expect(champ_migrated.type_de_champ.type_champ).to eq('piece_justificative')
        expect(champ_migrated.type_de_champ.titre_identite?).to be true
      end

      it "is idempotent for TypeDeChamp" do
        procedure_already_migrated = create(:procedure, types_de_champ_public: [
          { type: :piece_justificative, nature: "TITRE_IDENTITE", libelle: "Titre identité migré" },
        ])
        tdc_already_migrated = procedure_already_migrated.active_revision.types_de_champ_public.first

        batch = TypeDeChamp.where(id: tdc_already_migrated.id)

        expect {
          described_class.new.process(batch)
        }.not_to change { tdc_already_migrated.reload.updated_at }
      end

      it "is idempotent for Champs" do
        # Première migration
        batch = TypeDeChamp.where(id: tdc_1.id)
        described_class.new.process(batch)

        # Deuxième exécution
        initial_pj_count = Champ.where(type: 'Champs::PieceJustificativeChamp').count

        expect {
          described_class.new.process(batch)
        }.not_to change { Champ.where(type: 'Champs::PieceJustificativeChamp').count }.from(initial_pj_count)
      end

      it "migrates TypeDeChamp and Champs in a transaction" do
        # Simuler une erreur dans la migration des Champs
        allow_any_instance_of(described_class).to receive(:migrate_champs_for_type_de_champ).and_raise(StandardError, "Test error")

        batch = TypeDeChamp.where(id: tdc_1.id)

        expect {
          described_class.new.process(batch)
        }.to raise_error(StandardError, "Test error")

        # Vérifier que rien n'a été migré (rollback de la transaction)
        expect(tdc_1.reload.type_champ).to eq('titre_identite')
        expect(Champ.where(stable_id: tdc_1.stable_id, type: 'Champs::PieceJustificativeChamp').count).to eq(0)
      end

      it "preserves other TypeDeChamp attributes" do
        batch = TypeDeChamp.where(id: tdc_1.id)
        described_class.new.process(batch)

        expect(tdc_1.reload.libelle).to eq("CNI")
        expect(tdc_1.reload.stable_id).to be_present
      end
    end

    describe "#count" do
      let!(:procedure_with_ti) do
        create(:procedure).tap do |p|
          revision = p.active_revision
          revision.revision_types_de_champ.build(type_de_champ: build(:type_de_champ, type_champ: "titre_identite", libelle: "CNI"), position: 1)
          revision.revision_types_de_champ.build(type_de_champ: build(:type_de_champ, type_champ: "titre_identite", libelle: "Passeport"), position: 2)
          revision.save!
        end
      end

      let!(:procedure_with_pj) do
        create(:procedure, types_de_champ_public: [
          { type: :piece_justificative, libelle: "Justificatif" },
        ])
      end

      it "returns the count of titre_identite TypeDeChamp" do
        expect(described_class.new.count).to eq(2)
      end
    end
  end
end
