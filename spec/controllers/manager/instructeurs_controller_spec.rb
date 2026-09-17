# frozen_string_literal: true

describe Manager::InstructeursController, type: :controller do
  let(:super_admin) { create(:super_admin) }
  let(:instructeur) { create(:instructeur) }

  describe '#show' do
    render_views

    before do
      sign_in(super_admin)
      get :show, params: { id: instructeur.id }
    end

    it { expect(response.body).to include(instructeur.email) }
  end

  describe '#delete_edit' do
    render_views

    before { sign_in super_admin }

    it 'renders the confirmation page posting to the deletion' do
      get :delete_edit, params: { id: instructeur.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(instructeur.email)
      expect(response.body).to include("action=\"#{delete_manager_instructeur_path(instructeur)}\"")
    end
  end

  describe '#delete' do
    let(:super_admin) { create(:super_admin, :with_otp) }
    let(:otp_attempt) { current_otp_for(super_admin) }

    before { sign_in super_admin }

    subject { delete :delete, params: { id: instructeur.id, otp_attempt: } }

    it_behaves_like "a manager action gated by a fresh super-admin OTP" do
      let(:other_instructeur) { create(:instructeur) }
      let(:action_matcher) { change { Instructeur.where(id: [instructeur.id, other_instructeur.id]).count } }
      let(:replay_subject) { -> { delete :delete, params: { id: other_instructeur.id, otp_attempt: } } }
    end

    it 'deletes the instructeur' do
      subject

      expect(Instructeur.find_by(id: instructeur.id)).to be_nil
    end
  end
end
