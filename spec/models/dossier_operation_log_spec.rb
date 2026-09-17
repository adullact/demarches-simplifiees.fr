# frozen_string_literal: true

describe DossierOperationLog, type: :model do
  describe 'digest' do
    let(:instructeur) { create(:instructeur) }
    let(:dossier) { create(:dossier, :en_instruction, :with_individual) }

    def accepted_operation_from_database
      DossierOperationLog.create_and_serialize(
        dossier:,
        operation: DossierOperationLog.operations.fetch(:accepter),
        author: instructeur,
        subject: dossier
      )
      DossierOperationLog.find(dossier.dossier_operation_logs.last.id)
    end

    it 'matches the stored data' do
      operation = accepted_operation_from_database

      expect(Digest::SHA256.hexdigest(operation.data.to_json)).to eq(operation.digest)
    end

    it 'matches data holding -0, which the column stores as 0' do
      allow(SerializerService).to receive(:dossier).and_return({ 'value' => -0.0 })
      operation = accepted_operation_from_database

      expect(Digest::SHA256.hexdigest(operation.data.to_json)).to eq(operation.digest)
    end

    it 'matches the file moved to cold storage' do
      operation = accepted_operation_from_database
      operation.move_to_cold_storage!

      expect(Digest::SHA256.hexdigest(DossierOperationLog.find(operation.id).serialized.download)).to eq(operation.digest)
    end

    it 'matches the file handed to the administrateur export' do
      operation = accepted_operation_from_database
      documents = PiecesJustificativesService
        .new(user_profile: Administrateur.new, export_template: nil)
        .liste_documents([dossier])
      exported = documents.map(&:first).find { it.record_type == 'DossierOperationLog' }

      expect(Digest::SHA256.hexdigest(exported.file.read)).to eq(operation.digest)
    end
  end

  describe '.purge_discarded' do
    let(:dossier) { create(:dossier) }
    let!(:witness_dossier) do
      d = create(:dossier)

      DossierOperationLog.create_and_serialize(
        dossier: d,
        operation: DossierOperationLog.operations[:passer_en_instruction],
        author: instructeur
      )

      DossierOperationLog.create_and_serialize(
        dossier: d,
        operation: DossierOperationLog.operations[:supprimer],
        author: instructeur
      )

      d
    end

    let(:instructeur) { create(:instructeur) }

    def dols = dossier.dossier_operation_logs.reload
    def supprimer_dol = dols.find_by(operation: 'supprimer')
    def witness_dols = witness_dossier.dossier_operation_logs.reload
    def witness_supprimer_dol = witness_dols.find_by(operation: 'supprimer')

    it 'purges all operations but supprimer' do
      DossierOperationLog.create_and_serialize(
        dossier:,
        operation: DossierOperationLog.operations[:passer_en_instruction],
        author: instructeur
      )

      DossierOperationLog.create_and_serialize(
        dossier:,
        operation: DossierOperationLog.operations[:supprimer],
        author: instructeur
      )

      expect(dols.count).to eq(2)

      dols.purge_discarded

      expect(dols.map(&:operation)).to match_array('supprimer')
      expect(witness_dols.map(&:operation)).to match_array(['passer_en_instruction', 'supprimer'])
    end

    it 'destroys the serialized json from supprimer dol' do
      DossierOperationLog.create_and_serialize(
        dossier:,
        operation: DossierOperationLog.operations[:supprimer],
        author: instructeur
      )

      # serialize data attribute to json and store it to cold storage
      perform_enqueued_jobs do
        dols.each(&:move_to_cold_storage!)
        witness_dols.each(&:move_to_cold_storage!)
      end

      expect(supprimer_dol.serialized.attached?).to be true

      perform_enqueued_jobs { dols.purge_discarded }

      expect(supprimer_dol.serialized.attached?).to be false
      expect(witness_supprimer_dol.serialized.attached?).to be true
    end

    it 'nillifies the data attribut of not net seriaized supprimer dol' do
      DossierOperationLog.create_and_serialize(
        dossier:,
        operation: DossierOperationLog.operations[:supprimer],
        author: instructeur
      )

      expect(supprimer_dol.data).to be_present

      dols.purge_discarded

      expect(supprimer_dol.serialized.attached?).to be false
      expect(supprimer_dol.data).to be_nil
      expect(witness_supprimer_dol.data).to be_present
    end
  end
end
