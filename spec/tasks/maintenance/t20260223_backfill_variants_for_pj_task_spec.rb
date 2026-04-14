# frozen_string_literal: true

RSpec.describe Maintenance::T20260223BackfillVariantsForPjTask, :external_deps do
  describe '#process' do
    let(:procedure) { create(:procedure, types_de_champ_public: [{ type: :piece_justificative }]) }
    let(:dossier) { create(:dossier, :en_construction, :with_populated_champs, procedure:, depose_at: 1.day.ago) }

    subject(:task) do
      described_class.new.tap do |task|
        task.start_text = 2.days.ago.to_s
        task.end_text = Time.current.to_s
        task.file_type = 'pdf'
      end
    end

    it 'enqueues a BackfillVariantsForDossierJob for each dossier' do
      expect {
        task.process(dossier)
      }.to have_enqueued_job(BackfillVariantsForDossierJob).with(dossier.id, 'pdf')
    end

    context 'with default spread_duration_hours' do
      it 'defaults to 6 hours' do
        expect(task.spread_duration_hours).to eq(6)
      end
    end

    context 'with custom spread_duration_hours' do
      before { task.tap { _1.spread_duration_hours = 12 } }

      it 'uses the custom spread duration' do
        expect(task.spread_duration_hours).to eq(12)
      end
    end
  end

  describe '#collection' do
    let(:procedure) { create(:procedure, types_de_champ_public: [{ type: :piece_justificative }]) }

    let!(:dossier_in_range) { create(:dossier, :en_construction, procedure:, depose_at: 1.day.ago) }
    let!(:dossier_out_of_range) { create(:dossier, :en_construction, procedure:, depose_at: 10.days.ago) }
    let!(:dossier_brouillon) { create(:dossier, :brouillon, procedure:, depose_at: 1.day.ago) }

    subject(:task) do
      described_class.new.tap do |task|
        task.start_text = 2.days.ago.to_s
        task.end_text = Time.current.to_s
        task.file_type = ''
      end
    end

    it 'returns only dossiers in construction or instruction within date range' do
      expect(task.collection).to include(dossier_in_range)
      expect(task.collection).not_to include(dossier_out_of_range)
      expect(task.collection).not_to include(dossier_brouillon)
    end
  end
end
