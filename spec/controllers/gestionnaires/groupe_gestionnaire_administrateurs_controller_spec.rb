describe Gestionnaires::GroupeGestionnaireAdministrateursController, type: :controller do
  let(:gestionnaire) { create(:gestionnaire).tap { _1.user.update(last_sign_in_at: Time.zone.now) } }
  let(:other_admin) { create(:administrateur).tap { _1.user.update(last_sign_in_at: Time.zone.now) } }
  let!(:groupe_gestionnaire) { create(:groupe_gestionnaire, gestionnaires: [gestionnaire], administrateurs: [other_admin]) }
  render_views

  before do
    sign_in(gestionnaire.user)
  end

  describe '#create' do
    context 'as manager' do
      subject { post :create, params: { groupe_gestionnaire_id: groupe_gestionnaire.id, administrateur: { email: create(:administrateur).email } }, format: :turbo_stream }
      it { is_expected.to have_http_status(:ok) }
      it { expect { subject }.to change(groupe_gestionnaire.administrateurs, :count).by(1) }
    end
  end

  describe '#destroy' do

    def destroy_admin(admin_to_remove)
      delete :destroy, params: { groupe_gestionnaire_id: groupe_gestionnaire.id, id: admin_to_remove.id }, format: :turbo_stream
    end

    context 'when removing another admin' do
      before do
        destroy_admin(other_admin)
      end

      it 'removes the admin from the groupe_gestionnaire' do
        expect(response.body).to include('alert-success')
        expect(groupe_gestionnaire.administrateurs.reload).not_to include(other_admin)
      end
    end
  end
end
