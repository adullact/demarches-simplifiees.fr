# frozen_string_literal: true

require "rails_helper"

module Maintenance
  RSpec.describe T20241120UpdateBlobsServiceNameTask do
    before do
      ActiveStorage::Blob.insert!({ service_name: "scaleway", byte_size: 0, filename: "foo.txt", key: "lol" })
      ActiveStorage::Blob.insert!({ service_name: "amazon", byte_size: 0, filename: "foo.txt", key: "lol2" })
      ActiveStorage::Blob.insert!({ service_name: "local", byte_size: 0, filename: "foo.txt", key: "lol3" })
    end

    describe "#process" do
      subject(:process) { described_class.process(described_class.collection) }

      it "update the scaleway blobs to use the amazon service" do
        expect { subject }.to change(ActiveStorage::Blob.where(service_name: "amazon"), :count).by(1)
        expect(ActiveStorage::Blob.where(service_name: "scaleway")).to be_empty
        expect(ActiveStorage::Blob.where(service_name: "local")).to be_present
      end
    end
  end
end
