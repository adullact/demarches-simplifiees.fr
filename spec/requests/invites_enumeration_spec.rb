# frozen_string_literal: true

describe 'InvitesController account-existence oracle', type: :request do
  # Anonymous requests (no login_as): GET /invites/:id?email= must not reveal
  # whether an account exists for the given email. The id below matches no real
  # invitation, so the only thing that could drive a different response is the
  # existence of a User — which is exactly what must NOT leak.

  let(:forged_id) { (Invite.maximum(:id) || 0) + 1_000 }
  let(:email_with_account) { users.usager.email }
  let(:email_without_account) { 'no-such-user-xyz@example.com' }

  it 'sends an email WITH an account to sign in' do
    get invite_path(forged_id, email: email_with_account)
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'sends an email WITHOUT an account to the same sign-in page (uniform, no oracle)' do
    get invite_path(forged_id, email: email_without_account)
    expect(response).to redirect_to(new_user_session_path)
  end

  # Non-regression: a genuine invitation link still onboards a new invitee.
  it 'still sends a real invitee (matching invitation, no account) to registration' do
    invite = create(:invite, email: 'fresh-invitee-xyz@example.com', user: nil)

    get invite_path(invite.id, email: invite.email)

    expect(response).to redirect_to(new_user_registration_path(user: { email: invite.email }))
  end
end
