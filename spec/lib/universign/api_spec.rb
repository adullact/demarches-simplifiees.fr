describe Universign::API do
  describe '.request_timestamp', vcr: { cassette_name: 'universign' } do
    subject { described_class.timestamp(digest) }

    let(:digest) { Digest::SHA256.hexdigest("CECI EST UN HASH") }

    it do
      skip "L'URL de l'API Universign est obligatoire pour effectuer ce test" if UNIVERSIGN_API_URL.blank?
      is_expected.not_to be_nil
    end
  end
end
