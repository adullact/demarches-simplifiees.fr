# frozen_string_literal: true

describe RNFService do
  describe 'CA_BUNDLE' do
    it 'holds only the root CA published at interieur.gouv.fr/IGC/Certificat' do
      anchors = OpenSSL::X509::Certificate.load(File.read(described_class::CA_BUNDLE))

      expect(anchors.map { OpenSSL::Digest::SHA256.hexdigest(it.to_der) })
        .to eq(['79a1c910207c63a9875641c3955ccd1341338a5c5ebd8276846f8d2b3ce16727'])
    end
  end

  describe '#call' do
    let(:rnf_id) { '075-FDD-00003-01' }
    let(:url) { described_class.new.send(:url) }

    before do
      stub_request(:get, "#{url}/#{rnf_id}").to_return(body: '{}')
      allow(Typhoeus).to receive(:get).and_call_original
    end

    it 'passes that anchor and leaves the TLS verification on' do
      described_class.new.(rnf_id:)

      expect(Typhoeus).to have_received(:get).with(anything, hash_including(cainfo: described_class::CA_BUNDLE))
      expect(Typhoeus).to have_received(:get).with(anything, hash_excluding(:ssl_verifypeer, :ssl_verifyhost))
    end
  end
end
