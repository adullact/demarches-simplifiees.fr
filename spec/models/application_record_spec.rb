# frozen_string_literal: true

RSpec.describe ApplicationRecord, type: :model do
  describe '.record_from_typed_id' do
    subject { ApplicationRecord.record_from_typed_id(typed_id) }

    def typed_id_for(class_name, id) = GraphQL::Schema::UniqueWithinType.encode(class_name, id)

    context 'with a dossier visible by the administration' do
      let(:typed_id) { dossiers.en_construction.to_typed_id }

      it { is_expected.to eq(dossiers.en_construction) }
    end

    context 'with a dossier hidden from the administration' do
      let(:dossier) { dossiers.en_construction.tap { it.update!(hidden_by_administration_at: Time.zone.now) } }
      let(:typed_id) { dossier.to_typed_id }

      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'with a model the API loads from an argument' do
      let(:typed_id) { instructeurs.default.to_typed_id }

      it { is_expected.to eq(instructeurs.default) }
    end

    context 'with a model the API never loads from an argument' do
      let(:typed_id) { users.usager.to_typed_id }

      it 'does not resolve the constant' do
        expect(Object).not_to receive(:const_get)
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound, 'Unexpected object: User')
      end
    end

    context 'with a prefix that is not a model' do
      let(:typed_id) { typed_id_for('Kernel', 1) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound, 'Unexpected object: Kernel') }
    end

    context 'with an unknown record' do
      let(:typed_id) { typed_id_for('Instructeur', 0) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'with a malformed id' do
      let(:typed_id) { 'not-a-global-id' }

      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
