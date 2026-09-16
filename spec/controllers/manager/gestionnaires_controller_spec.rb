# frozen_string_literal: true

describe Manager::GestionnairesController, type: :controller do
  let(:super_admin) { create(:super_admin) }
  let(:gestionnaire) { create(:gestionnaire) }

  before { sign_in super_admin }

  describe '#index' do
    render_views

    it 'searches admin by email' do
      get :index, params: { search: gestionnaire.email }
      expect(response).to have_http_status(:success)
    end
  end

  describe '#show' do
    render_views

    before do
      get :show, params: { id: gestionnaire.id }
    end

    it { expect(response.body).to include(gestionnaire.email) }

    it 'links to the deletion confirmation page' do
      expect(response.body).to include(delete_edit_manager_gestionnaire_path(gestionnaire))
    end
  end

  describe '#delete_edit' do
    render_views

    it 'renders the confirmation page posting to the deletion' do
      get :delete_edit, params: { id: gestionnaire.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(gestionnaire.email)
      expect(response.body).to include("action=\"#{delete_manager_gestionnaire_path(gestionnaire)}\"")
    end
  end

  describe '#delete' do
    let(:super_admin) { create(:super_admin, :with_otp) }
    let(:otp_attempt) { current_otp_for(super_admin) }

    before { sign_in super_admin }

    subject { delete :delete, params: { id: gestionnaire.id, otp_attempt: } }

    it_behaves_like "a manager action gated by a fresh super-admin OTP" do
      let(:other_gestionnaire) { create(:gestionnaire) }
      let(:action_matcher) { change { Gestionnaire.where(id: [gestionnaire.id, other_gestionnaire.id]).count } }
      let(:replay_subject) { -> { delete :delete, params: { id: other_gestionnaire.id, otp_attempt: } } }
    end

    it 'deletes the gestionnaire' do
      subject

      expect(Gestionnaire.find_by(id: gestionnaire.id)).to be_nil
    end
  end
end
