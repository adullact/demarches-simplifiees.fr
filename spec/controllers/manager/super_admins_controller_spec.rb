# frozen_string_literal: true

describe Manager::SuperAdminsController, type: :controller do
  let!(:signed_in_super_admin) { create(:super_admin) }

  before { sign_in signed_in_super_admin }

  describe '#index' do
    render_views

    let!(:other_super_admin) { create(:super_admin) }

    context 'when the search term is a fragment of another super_admin encrypted_password' do
      let(:hash_fragment) { other_super_admin.encrypted_password[20, 15] }

      subject(:search_request) { get :index, params: { search: hash_fragment } }

      it 'does not match records by their password hash' do
        search_request
        expect(response.body).not_to include(other_super_admin.email)
      end
    end
  end

  describe 'POST #reset_otp' do
    let!(:signed_in_super_admin) { create(:super_admin, :with_otp) }
    let(:super_admin) { signed_in_super_admin }
    let(:target) { create(:super_admin, :with_otp) }
    let(:otp_attempt) { current_otp_for(super_admin) }

    subject { post :reset_otp, params: { id: target.id, otp_attempt: } }

    it_behaves_like "a manager action gated by a fresh super-admin OTP" do
      let(:action_matcher) { change { target.reload.otp_required_for_login } }
      let(:replay_subject) do
        -> { post :reset_otp, params: { id: target.id, otp_attempt: otp_attempt } }
      end
    end

    context 'with a fresh OTP code' do
      it 'disables the target OTP and redirects with a notice' do
        subject

        target.reload
        expect(target.otp_required_for_login).to be(false)
        expect(target.otp_secret).to be_nil
        expect(response).to redirect_to(manager_super_admin_path(target))
        expect(flash[:notice]).to include(target.email)
      end
    end

    context 'when targeting themselves' do
      it 'refuses and keeps their own OTP enabled' do
        expect { post :reset_otp, params: { id: super_admin.id, otp_attempt: } }
          .not_to change { super_admin.reload.otp_required_for_login }

        expect(response).to redirect_to(manager_super_admin_path(super_admin))
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #show' do
    render_views

    let!(:signed_in_super_admin) { create(:super_admin, :with_otp) }

    context 'when viewing another enrolled super admin' do
      let(:target) { create(:super_admin, :with_otp) }

      it 'shows the reset OTP button' do
        get :show, params: { id: target.id }
        expect(response.body).to include(reset_otp_edit_manager_super_admin_path(target))
      end
    end

    context 'when viewing a super admin without OTP' do
      let(:target) { create(:super_admin, otp_required_for_login: false) }

      it 'does not show the reset OTP button' do
        get :show, params: { id: target.id }
        expect(response.body).not_to include(reset_otp_edit_manager_super_admin_path(target))
      end
    end

    context 'when viewing themselves' do
      it 'does not show the reset OTP button' do
        get :show, params: { id: signed_in_super_admin.id }
        expect(response.body).not_to include(reset_otp_edit_manager_super_admin_path(signed_in_super_admin))
      end
    end

    it 'links to the deletion confirmation page' do
      target = create(:super_admin, :with_otp)

      get :show, params: { id: target.id }

      expect(response.body).to include(delete_edit_manager_super_admin_path(target))
    end

    it 'does not offer to delete their own account' do
      get :show, params: { id: signed_in_super_admin.id }

      expect(response.body).not_to include(delete_edit_manager_super_admin_path(signed_in_super_admin))
    end
  end

  describe 'DELETE #delete' do
    let!(:signed_in_super_admin) { create(:super_admin, :with_otp) }
    let(:super_admin) { signed_in_super_admin }
    let(:target) { create(:super_admin, :with_otp) }
    let(:otp_attempt) { current_otp_for(super_admin) }

    subject { delete :delete, params: { id: target.id, otp_attempt: } }

    it_behaves_like "a manager action gated by a fresh super-admin OTP" do
      let(:other_target) { create(:super_admin) }
      let(:action_matcher) { change { SuperAdmin.where(id: [target.id, other_target.id]).count } }
      let(:replay_subject) { -> { delete :delete, params: { id: other_target.id, otp_attempt: } } }
    end

    context 'with a fresh OTP code' do
      it 'deletes the account and redirects with a notice' do
        subject

        expect(SuperAdmin.find_by(id: target.id)).to be_nil
        expect(response).to redirect_to(manager_super_admins_path)
        expect(flash[:notice]).to include(target.email)
      end
    end

    context 'when targeting themselves' do
      it 'refuses and keeps their own account' do
        expect { delete :delete, params: { id: super_admin.id, otp_attempt: } }
          .not_to change { SuperAdmin.exists?(super_admin.id) }

        expect(response).to redirect_to(manager_super_admin_path(super_admin))
        expect(flash[:alert]).to be_present
      end
    end

    it 'does not route the destroy action inherited from Administrate' do
      expect(delete: "/manager/super_admins/#{target.id}").not_to be_routable
    end
  end

  describe 'GET #delete_edit' do
    render_views

    let!(:signed_in_super_admin) { create(:super_admin, :with_otp) }
    let(:target) { create(:super_admin, :with_otp) }

    it 'renders the confirmation page posting to the deletion' do
      get :delete_edit, params: { id: target.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(target.email)
      expect(response.body).to include("action=\"#{delete_manager_super_admin_path(target)}\"")
    end

    context 'when targeting themselves' do
      it 'refuses' do
        get :delete_edit, params: { id: signed_in_super_admin.id }

        expect(response).to redirect_to(manager_super_admin_path(signed_in_super_admin))
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #reset_otp_edit' do
    render_views

    let!(:signed_in_super_admin) { create(:super_admin, :with_otp) }
    let(:target) { create(:super_admin, :with_otp) }

    it 'renders the OTP step-up input' do
      get :reset_otp_edit, params: { id: target.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('name="otp_attempt"')
    end

    context 'when targeting themselves' do
      it 'refuses' do
        get :reset_otp_edit, params: { id: signed_in_super_admin.id }

        expect(response).to redirect_to(manager_super_admin_path(signed_in_super_admin))
        expect(flash[:alert]).to be_present
      end
    end
  end
end
