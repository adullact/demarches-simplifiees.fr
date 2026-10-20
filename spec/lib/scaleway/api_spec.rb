# frozen_string_literal: true

describe Scaleway::API do
  let(:api) { described_class.new }
  let(:email_address) { 'user@example.com' }

  def fixture_file(filename) = Rails.root.join('spec/fixtures/files/scaleway', filename).read

  describe '#sent_mails' do
    before do
      allow(ENV).to receive(:fetch).with('SCALEWAY_SECRET_KEY', nil).and_return('secret-key')
    end

    context 'when API returns emails' do
      before do
        stub_request(:get, /api\.scaleway\.com.*emails/)
          .with(query: hash_including(mail_rcpt: email_address))
          .to_return(body: fixture_file('emails.json'), status: 200)
      end

      it 'returns SentMail objects with correct mapping' do
        result = api.sent_mails(email_address)

        expect(result.length).to eq(2)
        expect(result).to all(be_a(SentMail))

        mail = result.first
        expect(mail.from).to eq('noreply@demarche-numerique.example.org')
        expect(mail.to).to eq('user@example.com')
        expect(mail.subject).to eq('Confirmation de creation de compte')
        expect(mail.status).to eq('sent')
        expect(mail.service_name).to eq('Scaleway')
        expect(mail.external_url).to include('console.scaleway.com')
        expect(mail.delivered_at).to be_a(ActiveSupport::TimeWithZone)
      end
    end

    context 'when API returns empty result or fails' do
      it 'returns empty array when no emails' do
        stub_request(:get, /api\.scaleway\.com.*emails/)
          .to_return(body: { emails: [], total_count: 0 }.to_json, status: 200)

        expect(api.sent_mails(email_address)).to eq([])
      end

      it 'returns empty array on API error and reports to Sentry' do
        stub_request(:get, /api\.scaleway\.com.*emails/)
          .to_return(body: 'Internal error', status: 500)
        allow(Sentry).to receive(:capture_message)

        expect(api.sent_mails(email_address)).to eq([])
        expect(Sentry).to have_received(:capture_message).with(/Scaleway API error/, anything)
      end

      it 'returns empty array when not configured' do
        allow(ENV).to receive(:fetch).with('SCALEWAY_SECRET_KEY', nil).and_return(nil)

        expect(api.sent_mails(email_address)).to eq([])
      end
    end
  end
end
