# frozen_string_literal: true

describe Manager::AdministrateursController, type: :controller do
  let(:super_admin) { create(:super_admin) }
  let(:administrateur) { administrateurs.default }

  before do
    sign_in super_admin
  end

  describe '#show' do
    let(:subject) { get :show, params: { id: administrateur.id } }

    context 'with 2FA not enabled' do
      let(:super_admin) { create(:super_admin, otp_required_for_login: false) }
      it { expect(subject).to redirect_to(edit_super_admin_otp_path) }
    end

    context 'with 2FA enabled' do
      render_views
      let(:super_admin) { create(:super_admin, otp_required_for_login: true) }

      before do
        subject
      end

      it 'offers to send the invitation again while the administrateur has not signed in' do
        expect(response.body).to include(administrateur.email)
        expect(response.body).to include("renvoyer l’invitation")
      end

      context 'when the administrateur has already signed in' do
        let(:administrateur) { administrateurs.blank.tap { it.user.update!(last_sign_in_at: Time.zone.now) } }

        it { expect(response.body).not_to include("renvoyer l’invitation") }
      end
    end
  end

  describe 'GET #new' do
    render_views
    it 'displays form to create a new admin' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:email) { 'plop@plop.com' }
    let(:password) { SECURE_PASSWORD }

    subject { post :create, params: { administrateur: { email: email } } }

    context 'when email and password are correct' do
      it 'add new administrateur in database' do
        expect { subject }.to change(Administrateur, :count).by(1)
      end

      it 'alert new mail are send' do
        allow(ProConnectService).to receive(:enabled?).and_return(false)
        expect(AdministrationMailer).to receive(:invite_admin).and_return(AdministrationMailer)
        expect(AdministrationMailer).to receive(:deliver_later)
        subject
      end

      it 'invites through ProConnect when the instance has it' do
        allow(ProConnectService).to receive(:enabled?).and_return(true)
        expect(AdministrationMailer).to receive(:invite_admin_via_pro_connect).and_return(AdministrationMailer)
        expect(AdministrationMailer).to receive(:deliver_later)
        subject
      end
    end

    context 'when email or password are missing' do
      let(:email) { '' }

      it { expect { subject }.to change(Administrateur, :count).by(0) }
    end
  end

  describe '#delete_edit' do
    render_views

    it 'renders the confirmation page posting to the deletion' do
      get :delete_edit, params: { id: administrateur.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(administrateur.email)
      expect(response.body).to include("action=\"#{delete_manager_administrateur_path(administrateur)}\"")
    end
  end

  describe '#delete' do
    # deletion needs an admin who owns nothing, not the shared default one
    let(:administrateur) { administrateurs.blank }
    let(:super_admin) { create(:super_admin, :with_otp) }
    let(:otp_attempt) { current_otp_for(super_admin) }

    subject { delete :delete, params: { id: administrateur.id, otp_attempt: } }

    it_behaves_like "a manager action gated by a fresh super-admin OTP" do
      let(:other_administrateur) { create(:administrateur) }
      let(:action_matcher) { change { Administrateur.where(id: [administrateur.id, other_administrateur.id]).count } }
      let(:replay_subject) { -> { delete :delete, params: { id: other_administrateur.id, otp_attempt: } } }
    end

    it 'deletes the admin' do
      subject

      expect(Administrateur.find_by(id: administrateur.id)).to be_nil
    end
  end

  describe '#index' do
    render_views

    it 'searches admin by email' do
      get :index, params: { search: administrateur.email }
      expect(response).to have_http_status(:success)
    end
  end
end
