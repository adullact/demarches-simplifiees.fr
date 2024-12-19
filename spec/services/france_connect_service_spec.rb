# frozen_string_literal: true

describe FranceConnectService do
  describe '.retrieve_user_informations_particulier' do
    let(:code) { 'plop' }
    let(:access_token) { +'my access_token' }

    let(:given_name) { 'plop1' }
    let(:family_name) { 'plop2' }
    let(:birthdate) { '2012-12-31' }
    let(:gender) { 'plop4' }
    let(:birthplace) { 'plop5' }
    let(:email) { 'plop@emaiL.com' }
    let(:phone) { '012345678' }
    let(:france_connect_particulier_id) { 'izhikziogjuziegj' }

    let(:user_info_hash) { { sub: france_connect_particulier_id, given_name: given_name, family_name: family_name, birthdate: birthdate, gender: gender, birthplace: birthplace, email: email, phone: phone } }
    let(:user_info) { instance_double('OpenIDConnect::ResponseObject::UserInfo', raw_attributes: user_info_hash) }

    subject { described_class.new(code: code).find_or_retrieve_france_connect_information }

    context 'when a code is given' do
      let(:code) { "2401d211-67df-43a0-9d9d-4ec0e01be3f2" }

      it 'returns user informations' do
        VCR.use_cassette("france_connect/success/token", erb: { fc_code: code }) do
          VCR.use_cassette("france_connect/success/userinfo") do
            expect(subject).to have_attributes(fci.attributes.except("created_at", "updated_at"))
          end
        end
      end
    end

    context 'when an invalid code is given' do
      let(:code) { "invalid" }

      it 'returns user informations' do
        VCR.use_cassette("france_connect/error/token", erb: { fc_code: code }) do
          expect { subject }.to raise_exception(Rack::OAuth2::Client::Error)
        end
      end
    end
  end
end
